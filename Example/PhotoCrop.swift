
import UIKit

public class PhotoCrop: UIView {
    
    let scrollView = PhotoCropScrollView()
    
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false

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
        
        // 当布局变化时，比如旋转屏幕
        // 需把图片完整的展现在 scrollView 中
        // 因此这里要计算缩放值，以及重置图片大小
        let scaleX = bounds.width / image.size.width
        let scaleY = bounds.height / image.size.height
        let scale = min(1, min(scaleX, scaleY))
 
        scrollView.zoomScale = scale
        scrollView.minimumZoomScale = scale
        
        print("\(scale) \(photoView.bounds) \(photoView.frame) \(image.size.width * scale)")
        // 根据 scale 修改图片的尺寸
//        photoView.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
        
        // 居中定位图片
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

