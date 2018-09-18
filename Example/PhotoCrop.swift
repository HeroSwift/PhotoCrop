
import UIKit

public class PhotoCrop: UIView {
    
    let scrollView = UIScrollView()
    
    let photoView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        photoView.image = UIImage(named: "bg")
        photoView.sizeToFit()
        
        scrollView.addSubview(photoView)
        scrollView.delegate = self
        scrollView.backgroundColor = .blue
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // min 和 max 必须不一样，否则不能缩放
        // 最大不能超过图片自身的尺寸，否则会模糊
        // 最小则需要计算
        scrollView.maximumZoomScale = 1
        
        addSubview(scrollView)
        
        
        
        addConstraints([
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        print(scrollView.frame)
        
        
        
    }
    
    func centerScrollViewContents() {
        let size = bounds.size
        var photoFrame = photoView.frame
        
        if photoFrame.size.width < size.width {
            photoFrame.origin.x = (size.width - photoFrame.size.width) / 2
        } else {
            photoFrame.origin.x = 0
        }
        
        if photoFrame.size.height < size.height {
            photoFrame.origin.y = (size.height - photoFrame.size.height) / 2
        } else {
            photoFrame.origin.y = 0
        }
        
        photoView.frame = photoFrame
    }
    
    public override func layoutSubviews() {
        
        guard let image = photoView.image else {
            return
        }
        
        let scaleX = bounds.width / image.size.width
        let scaleY = bounds.height / image.size.height
        let scale = min(1, min(scaleX, scaleY))
        
        scrollView.zoomScale = scale
        scrollView.minimumZoomScale = scale
        
        // 根据 scale 修改图片的尺寸
        photoView.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
        
        // 居中定位
        centerScrollViewContents()
    }
    
}

extension PhotoCrop: UIScrollViewDelegate {
    
    // 指定需要缩放的 view
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView 
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
}

