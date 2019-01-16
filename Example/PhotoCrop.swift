
import UIKit

public class PhotoCrop: UIView {
    
    var image: UIImage! {
        didSet {
            photoView.imageView.image = image
            foregroundView.imageView.image = image
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
        view.scaleType = .fit
        view.beforeSetContentInset = { contentInset in
            return self.isCropping ? self.maskedView.cropArea.toEdgeInsets() : contentInset
        }
        
        foregroundView.scrollView = view.scrollView
        
        return view
        
    }()
    
    // 裁剪器
    lazy public var maskedView: PhotoCropMaskView = {
       
        let view = PhotoCropMaskView()
        
        view.onCropAreaChange = { cropArea in
            let rect = cropArea.toRect(rect: self.bounds)
            self.foregroundView.frame = rect
            self.foregroundView.updateImagePosition()
        }
        view.onCropAreaResize = { cropArea in

            UIView.animate(withDuration: 0.5, animations: {
                self.cropArea = cropArea
                // 通过 UIScrollView 的 contentInset 设置滚动窗口的尺寸
                self.photoView.updateZoomScale()
            })
            
        }
        
        return view
    }()
    
    lazy var foregroundView: PhotoCropImageView = {

        return PhotoCropImageView()
        
    }()
    
    var cropArea = CropArea.zero {
        didSet {
            maskedView.cropArea = cropArea
            foregroundView.frame = cropArea.toRect(rect: bounds)
        }
    }
    
    // 旋转角度
    var angle = 0.0
    
    // 是否正在动画中
    var isAnimating = false
    
    var isCropping = false {
        didSet {
            
            if isCropping {
                
                rotateView.addSubview(maskedView)
                rotateView.addSubview(foregroundView)
                
                maskedView.alpha = 0
                
                photoView.scaleType = .fill
                
                // 初始化裁剪区域，和当前图片一样大
                // 这样就会有一个从大到小的动画
                cropArea = getCropAreaByContentInset(contentInset: photoView.scrollView.contentInset)
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.cropArea = self.maskedView.normalizeCropArea()
                        self.photoView.updateZoomScale()
                        self.maskedView.alpha = 1
                    })
                    
                }
                
            }
            else {
                
                foregroundView.removeFromSuperview()
                
                photoView.scaleType = .fit
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.photoView.updateZoomScale()
                    self.cropArea = self.getCropAreaByContentInset(contentInset: self.photoView.getContentInset())
                    self.maskedView.alpha = 0
                }, completion: { success in
                    self.maskedView.removeFromSuperview()
                })
                
            }
            
        }
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
        addSubview(rotateView)
        rotateView.addSubview(photoView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        rotateView.frame = bounds
        photoView.frame = bounds
        maskedView.frame = bounds
        
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
    
    public func reset() {
        
        
        
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

extension PhotoCrop {
    
    // 让 CropArea 完全包裹住图片，但又不超出屏幕
    private func getCropAreaByContentInset(contentInset: UIEdgeInsets) -> CropArea {
        let left = max(contentInset.left, maskedView.cornerLineWidth)
        let top = max(contentInset.top, maskedView.cornerLineWidth)
        let right = max(contentInset.right, maskedView.cornerLineWidth)
        let bottom = max(contentInset.bottom, maskedView.cornerLineWidth)
        return CropArea(top: top, left: left, bottom: bottom, right: right)
    }
    
}

