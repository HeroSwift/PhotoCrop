
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
            return self.isCropping ? self.overlayView.cropArea.toEdgeInsets() : contentInset
        }
        
        foregroundView.scrollView = view.scrollView
        
        return view
        
    }()
    
    // 裁剪器
    lazy public var overlayView: PhotoCropOverlay = {
       
        let view = PhotoCropOverlay()
        
        view.onCropAreaChange = { cropArea in
            self.foregroundView.frame = cropArea.toRect(rect: self.bounds)
        }
        view.onCropAreaResize = { cropArea in
            
            // 小值
            let oldRect = self.overlayView.cropArea.toRect(rect: self.bounds)
            // 大值
            let newRect = cropArea.toRect(rect: self.bounds)
            
            // 谁更大就用谁作为缩放系数
            let widthScale = newRect.width / oldRect.width
            let heightScale = newRect.height / oldRect.height
            let scale = max(widthScale, heightScale)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.foregroundView.save()
                
                self.cropArea = cropArea
                self.photoView.scrollView.zoomScale *= scale
                
                self.foregroundView.restore()
                
            })
        }
        
        return view
    }()
    
    lazy var foregroundView: PhotoCropForeground = {

        return PhotoCropForeground()
        
    }()
    
    var cropArea = CropArea.zero {
        didSet {
            overlayView.cropArea = cropArea
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
                
                rotateView.addSubview(overlayView)
                rotateView.addSubview(foregroundView)
                
                overlayView.alpha = 0
                
                photoView.scaleType = .fill
                
                // 初始化裁剪区域，和当前图片一样大
                // 这样就会有一个从大到小的动画
                cropArea = getCropAreaByContentInset(contentInset: photoView.scrollView.contentInset)
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.cropArea = self.overlayView.normalizeCropArea()
                        self.photoView.updateZoomScale()
                        self.overlayView.alpha = 1
                    })
                    
                }
                
            }
            else {
                
                foregroundView.removeFromSuperview()
                
                photoView.scaleType = .fit
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.photoView.updateZoomScale()
                    self.cropArea = self.getCropAreaByContentInset(contentInset: self.photoView.getContentInset())
                    self.overlayView.alpha = 0
                }, completion: { success in
                    self.overlayView.removeFromSuperview()
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
        overlayView.frame = bounds
        
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
        let left = max(contentInset.left, overlayView.cornerLineWidth)
        let top = max(contentInset.top, overlayView.cornerLineWidth)
        let right = max(contentInset.right, overlayView.cornerLineWidth)
        let bottom = max(contentInset.bottom, overlayView.cornerLineWidth)
        return CropArea(top: top, left: left, bottom: bottom, right: right)
    }
    
}

