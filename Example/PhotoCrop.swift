
import UIKit

public class PhotoCrop: UIView {
    
    var image: UIImage! {
        didSet {
            photoView.imageView.image = image
            foregroundView.image = image
        }
    }
    
    // 旋转容器
    private lazy var rotateView: UIView = {
        
        return UIView()
        
    }()
    
    // 图片容器，可缩放
    lazy var photoView: PhotoView = {
       
        let view = PhotoView()
        view.backgroundColor = .red
        view.scaleType = .fit
        view.beforeSetContentInset = { contentInset in
            return self.isCropping ? self.finderView.cropArea.toEdgeInsets() : contentInset
        }
        
        foregroundView.scrollView = view.scrollView
        
        return view
        
    }()
    
    private lazy var overlayView: PhotoCropOverlay = {
        
        return PhotoCropOverlay()
        
    }()
    
    // 裁剪器
    private lazy var finderView: PhotoCropFinder = {
       
        let view = PhotoCropFinder()
        
        view.onCropAreaChange = { cropArea in
            let rect = cropArea.toRect(rect: self.bounds)
            self.foregroundView.frame = rect
            self.gridView.frame = rect
        }
        view.onCropAreaResize = { cropArea in
            
            // 小值
            let oldRect = self.finderView.cropArea.toRect(rect: self.bounds)
            // 大值
            let newRect = cropArea.toRect(rect: self.bounds)
            
            // 谁更大就用谁作为缩放系数
            let widthScale = newRect.width / oldRect.width
            let heightScale = newRect.height / oldRect.height
            
            let oldValue = self.photoView.zoomScale
            let newValue = self.photoView.getZoomScale(scaledBy: max(widthScale, heightScale))
            
            if oldValue != newValue {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.foregroundView.save()

                    self.cropArea = cropArea
                    self.photoView.zoomScale = newValue
                    
                    self.foregroundView.restore()
                    
                })
            }
            else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.cropArea = cropArea
                })
            }
            
        }
        
        return view
    }()
    
    private lazy var foregroundView: PhotoCropForeground = {

        return PhotoCropForeground()
        
    }()
    
    private lazy var gridView: PhotoCropGrid = {
        
        return PhotoCropGrid()
        
    }()
    
    var cropArea = CropArea.zero {
        didSet {
            finderView.cropArea = cropArea
            foregroundView.frame = cropArea.toRect(rect: bounds)
        }
    }
    
    // 旋转角度
    var angle = 0.0
    
    var isCropping = false {
        didSet {
            
            if isCropping {
                
                rotateView.addSubview(overlayView)
                rotateView.addSubview(finderView)
                rotateView.addSubview(foregroundView)
                rotateView.addSubview(gridView)
                
                overlayView.alpha = 0
                finderView.alpha = 0
                gridView.alpha = 0
                
                photoView.scaleType = .fill
                
                // 初始化裁剪区域，和当前图片一样大
                // 这样就会有一个从大到小的动画
                cropArea = getCropAreaByContentInset(contentInset: photoView.scrollView.contentInset)
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.cropArea = self.finderView.normalizeCropArea()
                        self.photoView.updateZoomScale()
                        self.overlayView.alpha = 1
                        self.finderView.alpha = 1
                        self.gridView.alpha = 1
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
                    self.finderView.alpha = 0
                    self.gridView.alpha = 0
                }, completion: { success in
                    self.overlayView.removeFromSuperview()
                    self.finderView.removeFromSuperview()
                    self.gridView.removeFromSuperview()
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
        finderView.frame = bounds
        
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
        
        
    }
    
    public func reset() {
        
        
        
    }
    
}

extension PhotoCrop {
    
    // 让 CropArea 完全包裹住图片，但又不超出屏幕
    private func getCropAreaByContentInset(contentInset: UIEdgeInsets) -> CropArea {
        let left = max(contentInset.left, finderView.cornerLineWidth)
        let top = max(contentInset.top, finderView.cornerLineWidth)
        let right = max(contentInset.right, finderView.cornerLineWidth)
        let bottom = max(contentInset.bottom, finderView.cornerLineWidth)
        return CropArea(top: top, left: left, bottom: bottom, right: right)
    }
    
}

