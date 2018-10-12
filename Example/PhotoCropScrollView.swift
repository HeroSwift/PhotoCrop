
import UIKit

class PhotoCropScrollView: UIScrollView {
    
    private let photoView = UIImageView()
    
    var photo: UIImage! {
        didSet {
            
            photoView.image = photo
            photoView.frame.size = photo.size
            
            contentSize = photo.size

        }
    }
    
    var contentX: CGFloat {
        return contentInset.left
    }
    
    var contentY: CGFloat {
        return contentInset.top
    }
    
    var contentWidth: CGFloat {
        return bounds.width - contentInset.left - contentInset.right
    }
    
    var contentHeight: CGFloat {
        return bounds.height - contentInset.top - contentInset.bottom
    }
    
    var contentRect: CGRect {
        return CGRect(
            x: contentX,
            y: contentY,
            width: contentWidth,
            height: contentHeight
        )
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        // min 和 max 必须不一样，否则不能缩放
        // 最大不能超过图片自身的尺寸，否则会模糊
        // 最小则需要计算
        maximumZoomScale = 1
        
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        delegate = self
        
        addSubview(photoView)
        addObservers()
        
    }
    
    private func addObservers() {
        for forKeyPath in ["contentOffset", "contentSize"] {
            addObserver(self, forKeyPath: forKeyPath, options: [.new, .old], context: nil)
        }
    }
    
    private func removeObservers() {
        for forKeyPath in ["contentOffset", "contentSize"] {
            removeObserver(self, forKeyPath: forKeyPath)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        switch keyPath {
        case "contentOffset":
            updateContentOffset()
            break
        default:
            updateContentSize()
            break
        }
    }
    
    func updateFrame() {
        
        // 当布局变化时，比如旋转屏幕
        // 需把图片完整的展现在 scrollView 中
        // 因此这里要计算缩放值，以及重置图片大小
        let scaleX = contentWidth / photo.size.width
        let scaleY = contentHeight / photo.size.height
        let scale = min(1, min(scaleX, scaleY))
        
        // 展现完整的图片
        // 注意，必须先设置 minimumZoomScale 再设置 zoomScale
        // 否则旋转屏幕时，图片的尺寸不能正常复原
        maximumZoomScale = 1
        minimumZoomScale = scale
        zoomScale = scale
        
    }
    
    private func updateContentOffset() {
        print("contentOffset: \(contentOffset)")
    }
    
    private func updateContentSize() {
        print("contentSize: \(contentSize)")
    }
    
    func centerPhoto() {
        
        let width = contentWidth
        let height = contentHeight
        
        var viewFrame = photoView.frame
        
        if viewFrame.size.width < width {
            viewFrame.origin.x = (width - viewFrame.size.width) / 2
        }
        else {
            viewFrame.origin.x = 0
        }
        
        if viewFrame.size.height < height {
            viewFrame.origin.y = (height - viewFrame.size.height) / 2
        }
        else {
            viewFrame.origin.y = 0
        }
        
        photoView.frame = viewFrame
        
    }
    
}

extension PhotoCropScrollView: UIScrollViewDelegate {
    
    // 指定需要缩放的 view
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerPhoto()
    }
    
}

