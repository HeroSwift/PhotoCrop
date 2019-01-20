
import UIKit

public class PhotoCrop: UIView {
    
    public var image: UIImage! {
        didSet {
            photoView.imageView.image = image
            foregroundView.imageView.image = image
        }
    }
    
    // 图片容器，可缩放
    private lazy var photoView: PhotoView = {
       
        let view = PhotoView()
        view.backgroundColor = .red
        view.scaleType = .fit
        view.onScaleChange = {
            self.updateFinderMinSize()
        }
        
        foregroundView.photoView = view
        
        return view
        
    }()
    
    private lazy var overlayView: OverlayView = {
        
        let view = OverlayView()
        
        view.isHidden = true

        view.blurView.alpha = configuration.overlayAlpha

        return view
        
    }()
    
    // 裁剪器
    private lazy var finderView: FinderView = {
       
        let view = FinderView()
        
        view.isHidden = true
        view.configuration = configuration
        
        view.onCropAreaChange = {
            let rect = view.cropArea.toRect(width: self.bounds.width, height: self.bounds.height)
            self.foregroundView.frame = rect
            self.gridView.frame = rect
        }
        view.onCropAreaResize = {
            self.updateCropArea(by: self.finderView.normalizedCropArea)
        }
        
        return view
    }()
    
    private lazy var foregroundView: ForegroundView = {

        let view = ForegroundView()
        
        view.isHidden = true

        return view
        
    }()
    
    private lazy var gridView: GridView = {
        
        let view = GridView()
        
        view.isHidden = true
        view.configuration = configuration

        return view
        
    }()
    
    private var cropArea = CropArea.zero {
        didSet {
            finderView.cropArea = cropArea
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

                overlayView.isHidden = false
                finderView.isHidden = false
                foregroundView.isHidden = false
                gridView.isHidden = false
                
                overlayView.alpha = 0
                finderView.alpha = 0
                gridView.alpha = 0
                
                photoView.scaleType = .fill
                
                // 初始化裁剪区域，尺寸和当前图片一样大
                // 这样就会有一个从大到小的动画
                cropArea = getCropAreaByPhotoView()
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        let cropArea = self.finderView.normalizedCropArea
                        self.cropArea = cropArea
                        self.photoView.contentInset = cropArea.toEdgeInsets()
                        self.photoView.reset()
                        self.overlayView.alpha = 1
                        self.finderView.alpha = 1
                        self.gridView.alpha = 1
                    })
                    
                }
                
            }
            else {

                foregroundView.isHidden = true

                photoView.scaleType = .fit
                photoView.contentInset = nil
                
                // 从选定的裁剪区域到图片区域的动画
                UIView.animate(withDuration: 0.5, animations: {
                    self.photoView.reset()
                    self.cropArea = self.getCropAreaByPhotoView()
                    self.overlayView.alpha = 0
                    self.finderView.alpha = 0
                    self.gridView.alpha = 0
                }, completion: { success in
                    self.overlayView.isHidden = true
                    self.finderView.isHidden = true
                    self.gridView.isHidden = true
                })
                
            }
            
        }
    }
    
    private var configuration: PhotoCropConfiguration!

    public convenience init(configuration: PhotoCropConfiguration) {
        self.init()
        self.configuration = configuration
        addSubview(photoView)
        addSubview(overlayView)
        addSubview(finderView)
        addSubview(foregroundView)
        addSubview(gridView)
    }

    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        photoView.frame = bounds
        overlayView.frame = bounds
        finderView.frame = bounds

    }

    public func rotate() {
        
        let offset = Double.pi / 2
        
        angle += offset
        
        if angle.truncatingRemainder(dividingBy: 2 * Double.pi) == 0 {
            angle = 0
        }

        let transform = self.transform.rotated(by: CGFloat(offset))
        
        UIView.animate(withDuration: 1, animations: {
            self.transform = transform
        })
        
    }
    
    public func reset() {
        transform = CGAffineTransform.identity
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

    private func updateFinderMinSize() {
        finderView.updateMinSize(
            scaleFactor: photoView.maxScale / photoView.scale,
            minWidth: configuration.finderMinWidth,
            minHeight: configuration.finderMinHeight
        )
    }
    
    // CropArea 完全覆盖 PhotoView
    private func getCropAreaByPhotoView() -> CropArea {
        
        let imageOrigin = photoView.imageOrigin
        let imageSize = photoView.imageSize
        
        let left = max(imageOrigin.x, 0)
        let top = max(imageOrigin.y, 0)
        
        let right = max(photoView.frame.width - (imageOrigin.x + imageSize.width), 0)
        let bottom = max(photoView.frame.height - (imageOrigin.y + imageSize.height), 0)
        
        return CropArea(top: top, left: left, bottom: bottom, right: right)
        
    }
    
    private func updateCropArea(by cropArea: CropArea) {
        
        let width = bounds.width
        let height = bounds.height

        let oldRect = finderView.cropArea.toRect(width: width, height: height)
        let newRect = cropArea.toRect(width: width, height: height)
        
        // 谁更大就用谁作为缩放系数
        let widthScale = newRect.width / oldRect.width
        let heightScale = newRect.height / oldRect.height
        let scale = max(widthScale, heightScale)
        
        guard scale != 1 else {
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.foregroundView.save()
            
            self.cropArea = cropArea
            self.photoView.scale *= scale

            self.foregroundView.restore()
            
        })
        
    }
    
}

