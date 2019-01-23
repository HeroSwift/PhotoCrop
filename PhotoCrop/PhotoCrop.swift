
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
        
        view.scaleType = .fit
        view.backgroundColor = configuration.backgroundColor
        
        view.onScaleChange = {
            self.updateFinderMinSize()
            self.finderView.addInteractionTimer()
            self.foregroundView.updateImageSize()
        }
        view.onOriginChange = {
            self.finderView.addInteractionTimer()
            self.foregroundView.updateImageOrigin()
        }
        view.onReset = {
            self.foregroundView.updateImageSize()
            self.foregroundView.updateImageOrigin()
        }
        
        foregroundView.photoView = view
        
        return view
        
    }()
    
    private lazy var overlayView: OverlayView = {
        
        let view = OverlayView()
        
        view.isHidden = true

        view.blurView.alpha = configuration.overlayBlurAlpha

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
        view.onInteractionStart = {
            self.updateInteractionState(overlayAlpha: self.configuration.overlayAlphaInteractive, gridAlpha: 1)
        }
        view.onInteractionEnd = {
            self.updateInteractionState(overlayAlpha: self.configuration.overlayAlphaNormal, gridAlpha: 0)
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
        
        view.alpha = 0
        view.isHidden = true

        view.configuration = configuration

        return view
        
    }()
    
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

            finderView.stopInteraction()
            
            if isCropping {

                overlayView.isHidden = false
                finderView.isHidden = false
                foregroundView.isHidden = false
                gridView.isHidden = false
                
                overlayView.alpha = 0
                finderView.alpha = 0

                photoView.scaleType = .fill
                
                // 初始化裁剪区域，尺寸和当前图片一样大
                // 这样就会有一个从大到小的动画
                finderView.cropArea = getCropAreaByPhotoView()
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        let cropArea = self.finderView.normalizedCropArea
                        self.finderView.cropArea = cropArea
                        self.photoView.contentInset = cropArea.toEdgeInsets()
                        self.photoView.reset()
                        self.overlayView.alpha = self.configuration.overlayAlphaNormal
                        self.finderView.alpha = 1
                    })
                    
                }
                
            }
            else {

                photoView.scaleType = .fit
                photoView.contentInset = nil
                
                // 从选定的裁剪区域到图片区域的动画
                UIView.animate(withDuration: 0.5, animations: {
                    self.photoView.reset()
                    self.finderView.cropArea = self.getCropAreaByPhotoView()
                    self.overlayView.alpha = 0
                    self.finderView.alpha = 0
                    self.gridView.alpha = 0
                }, completion: { success in
                    self.overlayView.isHidden = true
                    self.finderView.isHidden = true
                    self.gridView.isHidden = true
                    self.foregroundView.isHidden = true
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
    
    public func crop() -> UIImage? {

        guard let image = photoView.imageView.image, isCropping else {
            return nil
        }

        let imageSize = image.size
        let cropRect = CGRect(
            x: abs(foregroundView.relativeX) * imageSize.width,
            y: abs(foregroundView.relativeY) * imageSize.height,
            width: foregroundView.relativeWidth * imageSize.width,
            height: foregroundView.relativeHeight * imageSize.height
        )
        
        if let croped = image.cgImage?.cropping(to: cropRect) {
            
            // 只有 @2x 图片才是 2
            // 但是 PhotoCrop 的场景没这样的，都是本地图片或网络图片
            let scale: CGFloat = 1
            
            var cropedImage = UIImage(cgImage: croped, scale: scale, orientation: image.imageOrientation)
            if cropedImage.imageOrientation == .up {
                return cropedImage
            }
            
            UIGraphicsBeginImageContextWithOptions(cropedImage.size, false, scale)
            cropedImage.draw(in: CGRect(origin: .zero, size: cropedImage.size))
            cropedImage = UIGraphicsGetImageFromCurrentImageContext() ?? cropedImage
            UIGraphicsEndImageContext()
            
            return cropedImage
            
        }
        
        return nil
        
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

        UIView.animate(withDuration: 0.3, animations: {
            
            self.foregroundView.save()
            
            self.finderView.cropArea = cropArea
            self.photoView.scale *= scale

            self.foregroundView.restore()
            
        })
        
    }
    
    private func updateInteractionState(overlayAlpha: CGFloat, gridAlpha: CGFloat) {
        
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = overlayAlpha
            self.gridView.alpha = gridAlpha
        }
        
    }
    
}

