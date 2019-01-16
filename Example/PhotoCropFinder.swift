
import UIKit

public class PhotoCropFinder: UIView {
    
    var borderLineWidth: CGFloat = 1
    var borderLineColor: UIColor = .white
    
    var cornerLineWidth: CGFloat = 3
    var cornerLineColor: UIColor = .white
    
    var cornerButtonWidth: CGFloat = 36
    var cornerButtonHeight: CGFloat = 36
    
    private lazy var borderLines: [UIView] = {
        return [createLine(color: borderLineColor), createLine(color: borderLineColor), createLine(color: borderLineColor), createLine(color: borderLineColor)]
    }()
    
    private lazy var topLeftCornerLines: [UIView] = {
        return [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
    }()
    private lazy var topRightCornerLines: [UIView] = {
        return [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
    }()
    private lazy var bottomLeftCornerLines: [UIView] = {
        return [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
    }()
    private lazy var bottomRightCornerLines: [UIView] = {
        return [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
    }()
    
    private lazy var cornerButtons: [UIView] = {
        return [createButton(), createButton(), createButton(), createButton()]
    }()
    
    // 裁剪的最小尺寸
    var minWidth: CGFloat = 100
    var minHeight: CGFloat = 100
    
    // 当改变尺寸时，是否保持比例
    var ratio: CGFloat = 1
    
    var onCropAreaChange: ((CropArea) -> Void)!
    var onCropAreaResize: ((CropArea) -> Void)!
    
    public override var frame: CGRect {
        didSet {
            size = frame.size
        }
    }
    
    var cropArea = CropArea.zero {
        didSet {
            updateCropArea()
            onCropAreaChange(cropArea)
        }
    }
    
    lazy var maxCropArea: CropArea = {
        return CropArea(top: cornerButtonHeight / 2, left: cornerButtonWidth / 2, bottom: cornerButtonHeight / 2, right: cornerButtonWidth / 2)
    }()
    
    private var resizeCropAreaTimer: Timer?
    
    private var size = CGSize.zero {
        didSet {
            
            guard size.width != oldValue.width || size.height != oldValue.height else {
                return
            }
            
            resizeCropArea()
            
        }
    }
    
    @objc func resize(gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let button = gestureRecognizer.view as? UIButton else {
            return
        }
        
        let state = gestureRecognizer.state
        guard state == .began || state == .changed else {
            if state == .ended {
                resizeCropAreaTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(resizeCropArea), userInfo: nil, repeats: false)
            }
            return
        }
        
        removeResizeCropAreaTimer()
        
        let viewWidth = size.width
        let viewHeight = size.height
        
        // 位移量
        let translation = gestureRecognizer.translation(in: self)
        let transX = translation.x
        let transY = translation.y
        
        // 裁剪区域
        var left = cropArea.left
        var top = cropArea.top
        
        var right = viewWidth - cropArea.right
        var bottom = viewHeight - cropArea.bottom
        
        let maxLeft = maxCropArea.left
        let maxTop = maxCropArea.top
        
        let maxRight = viewWidth - maxCropArea.right
        let maxBottom = viewHeight - maxCropArea.bottom
        
        switch button {
        case cornerButtons[0]:
            left = min(right - minWidth, max(maxLeft, left + transX))
            if ratio > 0 {
                top = bottom - (right - left) / ratio
            }
            else {
                top = min(bottom - minHeight, max(maxTop, top + transY))
            }
            break
        case cornerButtons[1]:
            right = min(maxRight, max(left + minWidth, right + transX))
            if ratio > 0 {
                top = bottom - (right - left) / ratio
            }
            else {
                top = min(bottom - minHeight, max(maxTop, top + transY))
            }
            break
        case cornerButtons[2]:
            right = min(maxRight, max(left + minWidth, right + transX))
            if ratio > 0 {
                bottom = top + (right - left) / ratio
            }
            else {
                bottom = min(maxBottom, max(top + minHeight, bottom + transY))
            }
            break
        default:
            left = min(right - minWidth, max(maxLeft, left + transX))
            if ratio > 0 {
                bottom = top + (right - left) / ratio
            }
            else {
                bottom = min(maxBottom, max(top + minHeight, bottom + transY))
            }
            break
        }
        
        cropArea = CropArea(top: top, left: left, bottom: viewHeight - bottom, right: viewWidth - right)
        
        gestureRecognizer.setTranslation(.zero, in: self)
        
    }
    
    func normalizeCropArea() -> CropArea {
        
        let width = size.width - cornerButtonWidth
        let height = width / ratio
        let top = (size.height - height) / 2
        let left = cornerButtonWidth / 2
        
        return CropArea(top: top, left: left, bottom: top, right: left)
        
    }
    
    @objc private func resizeCropArea() {
        removeResizeCropAreaTimer()
        onCropAreaResize(normalizeCropArea())
    }
    
    private func updateCropArea() {
        
        let left = cropArea.left
        let top = cropArea.top
        let right = size.width - cropArea.right
        let bottom = size.height - cropArea.bottom
        
        // 外围四条线
        borderLines[0].frame = CGRect(x: left, y: top - borderLineWidth, width: right - left, height: borderLineWidth)
        borderLines[1].frame = CGRect(x: right, y: top, width: borderLineWidth, height: bottom - top)
        borderLines[2].frame = CGRect(x: left, y: bottom, width: right - left, height: borderLineWidth)
        borderLines[3].frame = CGRect(x: left - borderLineWidth, y: top, width: borderLineWidth, height: bottom - top)
        
        // 四个角
        cornerButtons[0].frame.origin = CGPoint(x: left - cornerButtonWidth / 2, y: top - cornerButtonHeight / 2)
        topLeftCornerLines[0].frame.origin = CGPoint(x: left - cornerLineWidth, y: top - cornerLineWidth)
        topLeftCornerLines[1].frame.origin = CGPoint(x: left - cornerLineWidth, y: top - cornerLineWidth)
        
        cornerButtons[1].frame.origin = CGPoint(x: right - cornerButtonWidth / 2, y: top - cornerButtonHeight / 2)
        topRightCornerLines[0].frame.origin = CGPoint(x: right - cornerButtonWidth / 2, y: top - cornerLineWidth)
        topRightCornerLines[1].frame.origin = CGPoint(x: right, y: top - cornerLineWidth)
        
        cornerButtons[2].frame.origin = CGPoint(x: right + cornerLineWidth - cornerButtonWidth / 2, y: bottom - cornerButtonHeight / 2)
        bottomRightCornerLines[0].frame.origin = CGPoint(x: right + cornerLineWidth - cornerButtonWidth / 2, y: bottom)
        bottomRightCornerLines[1].frame.origin = CGPoint(x: right, y: bottom + cornerLineWidth - cornerButtonHeight / 2)
        
        cornerButtons[3].frame.origin = CGPoint(x: left - cornerButtonWidth / 2, y: bottom - cornerButtonHeight / 2)
        bottomLeftCornerLines[0].frame.origin = CGPoint(x: left - cornerLineWidth, y: bottom)
        bottomLeftCornerLines[1].frame.origin = CGPoint(x: left - cornerLineWidth, y: bottom - cornerButtonHeight / 2)
        
    }
    
    private func removeResizeCropAreaTimer() {
        resizeCropAreaTimer?.invalidate()
        resizeCropAreaTimer = nil
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        removeResizeCropAreaTimer()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        return cornerButtons.contains(view) ? view : nil
    }
    
    func cropPhoto(photo: UIImage, rect: CGRect) -> UIImage {
        
        var transform: CGAffineTransform
        
        switch photo.imageOrientation {
        case .left:
            transform = CGAffineTransform(rotationAngle: radians(90)).translatedBy(x: 0, y: -photo.size.height)
        case .right:
            transform = CGAffineTransform(rotationAngle: radians(-90)).translatedBy(x: -photo.size.width, y: 0)
        case .down:
            transform = CGAffineTransform(rotationAngle: radians(-180)).translatedBy(x: -photo.size.width, y: -photo.size.height)
        default:
            transform = CGAffineTransform.identity
        }
        
        transform = transform.scaledBy(x: photo.scale, y: photo.scale)
        
        if let croped = photo.cgImage?.cropping(to: rect.applying(transform)) {
            var cropedPhoto = UIImage(cgImage: croped, scale: photo.scale, orientation: photo.imageOrientation)
            if cropedPhoto.imageOrientation == .up {
                return cropedPhoto
            }
            
            UIGraphicsBeginImageContextWithOptions(cropedPhoto.size, false, cropedPhoto.scale)
            cropedPhoto.draw(in: CGRect(origin: .zero, size: cropedPhoto.size))
            cropedPhoto = UIGraphicsGetImageFromCurrentImageContext() ?? cropedPhoto
            UIGraphicsEndImageContext()
            
            return cropedPhoto
        }
        
        return photo
        
    }
    
}

extension PhotoCropFinder {

    private func createLine(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        return line
    }
    
    private func createHorizontalCornerLine(color: UIColor) -> UIView {
        let line = createLine(color: color)
        line.frame = CGRect(x: 0, y: 0, width: cornerButtonWidth / 2, height: cornerLineWidth)
        return line
    }
    
    private func createVerticalCornerLine(color: UIColor) -> UIView {
        let line = createLine(color: color)
        line.frame = CGRect(x: 0, y: 0, width: cornerLineWidth, height: cornerButtonHeight / 2)
        return line
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: 0, width: cornerButtonWidth, height: cornerButtonHeight)
        button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(resize)))
        addSubview(button)
        return button
    }
    
}

internal func radians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180 * .pi
}

