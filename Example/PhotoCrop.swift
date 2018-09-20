
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

        addSubview(scrollView)

    }
    
    public override func layoutSubviews() {
        
        guard let image = photoView.image else {
            return
        }
        
        scrollView.frame = CGRect(origin: .zero, size: bounds.size)

        // 当布局变化时，比如旋转屏幕
        // 需把图片完整的展现在 scrollView 中
        // 因此这里要计算缩放值，以及重置图片大小
        let scaleX = scrollView.contentWidth / image.size.width
        let scaleY = scrollView.contentHeight / image.size.height
        let scale = min(1, min(scaleX, scaleY))
 
        scrollView.zoomScale = scale
        scrollView.minimumZoomScale = scale
        
        print("\(scale) \(photoView.bounds) \(photoView.frame) \(image.size.width * scale)")
        // 根据 scale 修改图片的尺寸
//        photoView.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
        
        // 居中定位图片
        scrollView.centerContent(view: photoView)
    }
    
}

extension PhotoCrop: UIScrollViewDelegate {
    
    // 指定需要缩放的 view
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView 
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.scrollView.centerContent(view: photoView)
    }
    
}

