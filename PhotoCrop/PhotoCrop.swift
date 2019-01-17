
import UIKit

public class PhotoCrop: UIView {
    
    public var image: UIImage! {
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
    private lazy var photoView: PhotoView = {
       
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
        
        let view = PhotoCropOverlay()
        view.blurView.alpha = configuration.overlayAlpha
        
        return PhotoCropOverlay()
        
    }()
    
    // 裁剪器
    private lazy var finderView: PhotoCropFinder = {
       
        let view = PhotoCropFinder()
        
        view.configuration = configuration

        view.onCropAreaChange = { cropArea in
            let rect = cropArea.toRect(rect: self.bounds)
            self.foregroundView.frame = rect
            self.gridView.frame = rect
        }
        view.onCropAreaResize = {
            
            // 小值
            let oldRect = self.finderView.cropArea.toRect(rect: self.bounds)
            
            // 大值
            let cropArea = self.finderView.normalizedCropArea
            let newRect = cropArea.toRect(rect: self.bounds)
            
            // 谁更大就用谁作为缩放系数
            let widthScale = newRect.width / oldRect.width
            let heightScale = newRect.height / oldRect.height
            
            let oldValue = self.photoView.scale
            let newValue = oldValue * max(widthScale, heightScale)
            
            if oldValue != newValue {
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.foregroundView.save()

                    self.cropArea = cropArea
                    self.photoView.scale = newValue
                    
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

        let view = PhotoCropForeground()
        
        view.onScaleFactorChange = {
            self.updateFinderMinSize()
        }
        
        return view
        
    }()
    
    private lazy var gridView: PhotoCropGrid = {
        
        let view = PhotoCropGrid()
        
        view.lineWidth = configuration.gridLineWidth
        view.lineColor = configuration.gridLineColor
        
        return view
        
    }()
    
    private var cropArea = PhotoCropArea.zero {
        didSet {
            finderView.cropArea = cropArea
            foregroundView.frame = cropArea.toRect(rect: bounds)
        }
    }
    
    private var angle: Double = 0
    
    private var isReversed: Bool {
        get {
            return angle.truncatingRemainder(dividingBy: Double.pi) != 0
        }
    }
    
    public var isCropping = false {
        didSet {
            
            guard isCropping != oldValue else {
                return
            }
            
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
                        self.cropArea = self.finderView.normalizedCropArea
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
    
    private var configuration: PhotoCropConfiguration!

    public convenience init(configuration: PhotoCropConfiguration) {
        self.init()
        self.configuration = configuration
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
        
        updateFinderMinSize()

    }

    public func rotate() {
        
        let offset = Double.pi / 2
        
        angle += offset
        
        if angle.truncatingRemainder(dividingBy: 2 * Double.pi) == 0 {
            angle = 0
        }

        let transform = rotateView.transform.rotated(by: CGFloat(offset))
        
        UIView.animate(withDuration: 1, animations: {
            self.rotateView.transform = transform
        })
        
    }
    
    public func reset() {
        rotateView.transform = CGAffineTransform.identity
    }
    
    public func crop() -> UIImage {
        
//        var transform: CGAffineTransform
        
//        switch photo.imageOrientation {
//        case .left:
//            transform = CGAffineTransform(rotationAngle: radians(90)).translatedBy(x: 0, y: -photo.size.height)
//        case .right:
//            transform = CGAffineTransform(rotationAngle: radians(-90)).translatedBy(x: -photo.size.width, y: 0)
//        case .down:
//            transform = CGAffineTransform(rotationAngle: radians(-180)).translatedBy(x: -photo.size.width, y: -photo.size.height)
//        default:
//            transform = CGAffineTransform.identity
//        }
        
//        transform = transform.scaledBy(x: photo.scale, y: photo.scale)
        
        if let croped = image.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 100, height: 100)) {
            
            let scale = image.scale
            var cropedPhoto = UIImage(cgImage: croped, scale: scale, orientation: image.imageOrientation)
            if cropedPhoto.imageOrientation == .up {
                return cropedPhoto
            }
            
            UIGraphicsBeginImageContextWithOptions(cropedPhoto.size, false, cropedPhoto.scale)
            cropedPhoto.draw(in: CGRect(origin: .zero, size: cropedPhoto.size))
            cropedPhoto = UIGraphicsGetImageFromCurrentImageContext() ?? cropedPhoto
            UIGraphicsEndImageContext()
            
            return cropedPhoto
        }
        
        return image
        
    }
    
}

extension PhotoCrop {
    
    // 让 CropArea 完全包裹住图片，但又不超出屏幕
    private func getCropAreaByContentInset(contentInset: UIEdgeInsets) -> PhotoCropArea {
        let left = max(contentInset.left, configuration.finderCornerLineWidth)
        let top = max(contentInset.top, configuration.finderCornerLineWidth)
        let right = max(contentInset.right, configuration.finderCornerLineWidth)
        let bottom = max(contentInset.bottom, configuration.finderCornerLineWidth)
        return PhotoCropArea(top: top, left: left, bottom: bottom, right: right)
    }
    
    private func updateFinderMinSize() {
        finderView.updateMinSize(
            scaleFactor: foregroundView.scaleFactor,
            minWidth: configuration.finderMinWidth,
            minHeight: configuration.finderMinHeight
        )
    }
}

