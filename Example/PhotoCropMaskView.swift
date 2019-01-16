
import UIKit

class CropArea {
    
    static let zero = CropArea(top: 0, left: 0, bottom: 0, right: 0)
    
    var top: CGFloat
    var left: CGFloat
    var bottom: CGFloat
    var right: CGFloat
    
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    func toRect(rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x + left, y: rect.origin.y + top, width: rect.width - left - right, height: rect.height - top - bottom)
    }
    
    func toEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
}

public class PhotoCropMaskView: UIView {
    
    var outerLineWidth: CGFloat = 1
    var outerLineColor: UIColor = .white
    
    var innerLineWidth: CGFloat = 1 / UIScreen.main.scale
    var innerLineColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    
    var cornerLineWidth: CGFloat = 3
    var cornerLineColor: UIColor = .white
    
    var cornerButtonWidth: CGFloat = 36
    var cornerButtonHeight: CGFloat = 36
    
    
    
    var outerLines = [UIView]()
    
    var horizontalLines = [UIView]()
    var verticalLines = [UIView]()
    
    var topLeftCornerLines = [UIView]()
    var topRightCornerLines = [UIView]()
    var bottomLeftCornerLines = [UIView]()
    var bottomRightCornerLines = [UIView]()
    
    var cornerButtons = [UIView]()

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

            blueEffectView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            resizeCropArea()
            
        }
    }

    private lazy var blueEffectView: UIVisualEffectView = {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.alpha = 0.3
        
        insertSubview(view, at: 0)

        return view
        
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
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
        outerLines[0].frame = CGRect(x: left, y: top - outerLineWidth, width: right - left, height: outerLineWidth)
        outerLines[1].frame = CGRect(x: right, y: top, width: outerLineWidth, height: bottom - top)
        outerLines[2].frame = CGRect(x: left, y: bottom, width: right - left, height: outerLineWidth)
        outerLines[3].frame = CGRect(x: left - outerLineWidth, y: top, width: outerLineWidth, height: bottom - top)
        
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
        
        // 中间的横竖线
        let rowSpacing = (bottom - top) / CGFloat(horizontalLines.count + 1)
        let columnSpacing = (right - left) / CGFloat(verticalLines.count + 1)
        
        for (i, line) in horizontalLines.enumerated() {
            let offset = rowSpacing * CGFloat(i + 1) + innerLineWidth * CGFloat(i)
            line.frame = CGRect(x: left, y: top + offset, width: right - left, height: innerLineWidth)
        }
        
        for (i, line) in verticalLines.enumerated() {
            let offset = columnSpacing * CGFloat(i + 1) + innerLineWidth * CGFloat(i)
            line.frame = CGRect(x: left + offset, y: top, width: innerLineWidth, height: bottom - top)
        }

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

extension PhotoCropMaskView {
    
    private func setup() {
        
        backgroundColor = .clear
        
        outerLines = [createLine(color: outerLineColor), createLine(color: outerLineColor), createLine(color: outerLineColor), createLine(color: outerLineColor)]
        horizontalLines = [createLine(color: innerLineColor), createLine(color: innerLineColor)]
        verticalLines = [createLine(color: innerLineColor), createLine(color: innerLineColor)]
        
        topLeftCornerLines = [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
        topRightCornerLines = [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
        bottomLeftCornerLines = [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
        bottomRightCornerLines = [createHorizontalCornerLine(color: cornerLineColor), createVerticalCornerLine(color: cornerLineColor)]
        
        cornerButtons = [createButton(), createButton(), createButton(), createButton()]
        
    }
    
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

