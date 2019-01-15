
import UIKit

public class PhotoCrop: UIView {
    
    var image: UIImage! {
        didSet {
            photoView.imageView.image = image
            updateCropAreaByImageView()
        }
    }
    
    // 旋转容器
    private lazy var rotateView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
        
    }()
    
    // 图片容器，可缩放
    lazy var photoView: PhotoView = {
       
        let view = PhotoView()
        view.backgroundColor = .red

        return view
        
    }()
    
    // 裁剪器
    let cropView = PhotoCropOverlay()
    
    // 旋转角度
    var angle = 0.0
    
    // 是否正在动画中
    var isAnimating = false
    
    private var currentRect: CGRect {
        return CGRect(
            origin: .zero,
            size: angle.truncatingRemainder(dividingBy: Double.pi) == 0
                ? frame.size
                : CGSize(width: frame.size.height, height: frame.size.width)
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

        backgroundColor = .blue
        
        addSubview(rotateView)
        
        rotateView.addSubview(photoView)
        
    }
    
    public override func layoutSubviews() {
        
        rotateView.frame = bounds
        photoView.frame = bounds
        cropView.frame = bounds
        
        // 这句很重要
        // 根据当前的旋转角度设置 frame
//        photoView.frame = currentRect

    }
    
    public func rotate(animationDuration: TimeInterval = 0.5, options: UIView.AnimationOptions = .curveEaseInOut) {
        
        angle += Double.pi / 2
        
        let animations: () -> Void = {
            self.rotateView.transform = CGAffineTransform(rotationAngle: CGFloat(self.angle))
            self.layoutSubviews()
        }
        
        let completion: (Bool) -> Void = { finished in
            if self.angle == 2 * Double.pi {
                self.angle = 0
            }
        }
        
        animate(animationDuration: animationDuration, options: options, animations: animations, completion: completion)
        
    }
    
    public func reset(animationDuration: TimeInterval = 0.3, options: UIView.AnimationOptions = .curveEaseInOut) {
        
        
        
    }
    
    public func showCropOverlay(animationDuration: TimeInterval = 0.3, options: UIView.AnimationOptions = .curveEaseInOut) {
        
        
        rotateView.addSubview(cropView)
        
        
        let animations: () -> Void = {
            
        }
        
        let completion: (Bool) -> Void = { finished in
            
        }
        
        animate(animationDuration: animationDuration, options: options, animations: animations, completion: completion)
        
    }
    
    public func hideCropOverlay() {
        
        cropView.removeFromSuperview()
        updateCropAreaByImageView()
        
    }
    
    private func updateCropAreaByImageView() {
        let frame = photoView.imageView.frame
        cropView.cropArea = CropArea(top: frame.origin.y, left: frame.origin.x, bottom: frame.origin.y + frame.height, right: frame.origin.x + frame.width)
    }
    
    private func center() {
        
        
    }
    
    private func animate(animationDuration: TimeInterval = 0.5, options: UIView.AnimationOptions = .curveEaseInOut, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        
        isAnimating = true
        
        let animationCompletion: (Bool) -> Void = { finished in
            self.isAnimating = false
            completion?(finished)
        }
        
        if animationDuration > 0 {
            UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: animations, completion: animationCompletion)
        }
        else {
            animations()
            animationCompletion(true)
        }
    }
    
}



