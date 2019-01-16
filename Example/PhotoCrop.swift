
import UIKit

public class PhotoCrop: UIView {
    
    var image: UIImage! {
        didSet {
            photoView.imageView.image = image
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
            return self.isCropping ? self.cropView.cropArea.toEdgeInsets() : contentInset
        }

        return view
        
    }()
    
    // 裁剪器
    lazy var cropView: PhotoCropOverlay = {
       
        let view = PhotoCropOverlay()
        view.onResizeCropArea = { cropArea in
            self.updateCropAreaByImageView(cropArea: cropArea)
        }
        return view
    }()
    
    // 旋转角度
    var angle = 0.0
    
    // 是否正在动画中
    var isAnimating = false
    
    var isCropping = false {
        didSet {
            
            if isCropping {
                
                rotateView.addSubview(cropView)
                cropView.alpha = 0
                
                // 先把 crop area 调整成和当前图片一样大
                cropView.cropArea = getCropAreaByContentInset(contentInset: photoView.scrollView.contentInset)
                
                // 等一下(为了触发动画)，调整成符合比例的裁剪框
                let cropArea = cropView.normalizeCropArea()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.photoView.scaleType = .fill
                    self.updateCropAreaByImageView(cropArea: cropArea)
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.cropView.alpha = 1
                    })
                    
                }
                
            }
            else {
                
                photoView.scaleType = .fit
                updateCropAreaByImageView(cropArea: getCropAreaByContentInset(contentInset: photoView.getContentInset()))
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.cropView.alpha = 0
                }, completion: { success in
                    self.cropView.removeFromSuperview()
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
    
    private func updateCropAreaByImageView(cropArea: CropArea) {
        

        UIView.animate(withDuration: 2, animations: {
            self.cropView.cropArea = cropArea
            // 通过 UIScrollView 的 contentInset 设置滚动窗口的尺寸
            self.photoView.updateZoomScale()
        })

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
        let left = max(contentInset.left, cropView.cornerLineWidth)
        let top = max(contentInset.top, cropView.cornerLineWidth)
        let right = max(contentInset.right, cropView.cornerLineWidth)
        let bottom = max(contentInset.bottom, cropView.cornerLineWidth)
        return CropArea(top: top, left: left, bottom: bottom, right: right)
    }
    
    
}

