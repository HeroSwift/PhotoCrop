
import UIKit

class PhotoCropScrollView: UIScrollView {
    
    let photoView = UIImageView()
    
    var photo: UIImage! {
        didSet {
            
            zoomScale = 1
       
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
        
        contentInset = UIEdgeInsetsMake(10, 10, 10, 10)

        addSubview(photoView)
        
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
        print("\(keyPath) is changed")
    }
    
    func centerContent(view: UIView) {
        
        let width = contentWidth
        let height = contentHeight
        
        var viewFrame = view.frame
        
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
        
        view.frame = viewFrame
        
    }
    
}
