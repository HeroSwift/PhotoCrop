
import UIKit

public class PhotoCropOverlay: UIView {
    
    var outerLines = [UIView]()
    
    var horizontalLines = [UIView]()
    var verticalLines = [UIView]()
    
    var topLeftCornerLines = [UIView]()
    var topRightCornerLines = [UIView]()
    var bottomLeftCornerLines = [UIView]()
    var bottomRightCornerLines = [UIView]()
    
    var cornerButtons = [UIButton]()

    var outerLineWidth = CGFloat(1)
    var outerLineColor = UIColor.white
    
    var innerLineWidth = CGFloat(1) / UIScreen.main.scale
    var innerLineColor = UIColor.white.withAlphaComponent(0.5)

    var cornerLineWidth = CGFloat(3)
    var cornerLineColor = UIColor.white
    
    var cornerButtonWidth = CGFloat(26)
    var cornerButtonHeight = CGFloat(26)
    
    var minWidth = CGFloat(100)
    var minHeight = CGFloat(100)
    
    // 是否可改变尺寸
    var isResizable = true
    
    // 是否可移动
    var isMovable = true
    
    // 当改变尺寸时，是否保持比例
    var ratio = CGFloat(16.0 / 9.0)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .clear
        
        let mask = createMask()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.6
        
        blurEffectView.frame = mask.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mask.addSubview(blurEffectView)
        
        outerLines = [createLine(color: outerLineColor), createLine(color: outerLineColor), createLine(color: outerLineColor), createLine(color: outerLineColor)]
        horizontalLines = [createLine(color: innerLineColor), createLine(color: innerLineColor)]
        verticalLines = [createLine(color: innerLineColor), createLine(color: innerLineColor)]
        
        topLeftCornerLines = [createLine(color: cornerLineColor), createLine(color: cornerLineColor)]
        topRightCornerLines = [createLine(color: cornerLineColor), createLine(color: cornerLineColor)]
        bottomLeftCornerLines = [createLine(color: cornerLineColor), createLine(color: cornerLineColor)]
        bottomRightCornerLines = [createLine(color: cornerLineColor), createLine(color: cornerLineColor)]
        
        cornerButtons = [createButton(), createButton(), createButton(), createButton()]
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(move)))
        
        if ratio > 0 && bounds.width / bounds.height != ratio {
            frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: frame.size.width / ratio))
        }
        
    }
    
    private func createMask() -> UIView {
        let mask = UIView()
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(mask)
        return mask
    }
    
    private func createLine(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        return line
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(resize)))
        addSubview(button)
        return button
    }
    
    @objc func resize(gestureRecognizer: UIPanGestureRecognizer) {
        guard isResizable, let button = gestureRecognizer.view as? UIButton, gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            return
        }
        let translation = gestureRecognizer.translation(in: self)
        
        let superBounds = self.superview!.bounds
        
        var left = frame.origin.x
        var top = frame.origin.y
        var right = left + frame.size.width
        var bottom = top + frame.size.height
        
        switch button {
        case cornerButtons[0]:
            left = min(right - minWidth, max(0, left + translation.x))
            if ratio > 0 {
                top = bottom - (right - left) / ratio
            }
            else {
                top = min(bottom - minHeight, max(0, top + translation.y))
            }
            break
        case cornerButtons[1]:
            right = min(superBounds.width, max(left + minWidth, right + translation.x))
            if ratio > 0 {
                top = bottom - (right - left) / ratio
            }
            else {
                top = min(bottom - minHeight, max(0, top + translation.y))
            }
            break
        case cornerButtons[2]:
            right = min(superBounds.width, max(left + minWidth, right + translation.x))
            if ratio > 0 {
                bottom = top + (right - left) / ratio
            }
            else {
                bottom = min(superBounds.height, max(top + minHeight, bottom + translation.y))
            }
            break
        default:
            left = min(right - minWidth, max(0, left + translation.x))
            if ratio > 0 {
                bottom = top + (right - left) / ratio
            }
            else {
                bottom = min(superBounds.height, max(top + minHeight, bottom + translation.y))
            }
            break
        }
        
        frame = CGRect(
            x: left,
            y: top,
            width: right - left,
            height: bottom - top
        )
        
        setNeedsLayout()
        
        gestureRecognizer.setTranslation(.zero, in: self)
        
    }
    
    @objc func move(gestureRecognizer: UIPanGestureRecognizer) {
        guard isMovable, gestureRecognizer.state == .began || gestureRecognizer.state == .changed else {
            return
        }
        let translation = gestureRecognizer.translation(in: self)
        
        let superBounds = self.superview!.bounds
        
        var centerX = center.x + translation.x
        var centerY = center.y + translation.y
        
        if centerX - bounds.width / 2 < 0 {
            centerX = bounds.width / 2
        }
        else if centerX + bounds.width / 2 > superBounds.width {
            centerX = superBounds.width - bounds.width / 2
        }
        
        if centerY - bounds.height / 2 < 0 {
            centerY = bounds.height / 2
        }
        else if centerY + bounds.height / 2 > superBounds.height {
            centerY = superBounds.height - bounds.height / 2
        }

        center = CGPoint(x: centerX, y: centerY)
        gestureRecognizer.setTranslation(.zero, in: self)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if !isMovable && isResizable && view != nil {
            let isButton = cornerButtons.reduce(false) { $1.hitTest(convert(point, to: $1), with: event) != nil || $0 }
            if !isButton {
                return nil
            }
        }
        return view
    }
    
    public override func layoutSubviews() {
        
        // 外围四条线
        for i in 0..<outerLines.count {
            let line = outerLines[i]
            let lineFrame: CGRect
            
            switch i {
            case 0:
                lineFrame = CGRect(x: cornerButtonWidth, y: cornerButtonHeight / 2, width: bounds.width - cornerButtonWidth * 2, height: outerLineWidth)
                break
            case 1:
                lineFrame = CGRect(x: bounds.width - cornerButtonWidth / 2 - outerLineWidth, y: cornerButtonHeight, width: outerLineWidth, height: bounds.height - cornerButtonHeight * 2)
                break
            case 2:
                lineFrame = CGRect(x: cornerButtonWidth, y: bounds.height - cornerButtonHeight / 2 - outerLineWidth, width: bounds.width - cornerButtonWidth * 2, height: outerLineWidth)
                break
            default:
                lineFrame = CGRect(x: cornerButtonWidth / 2, y: cornerButtonHeight, width: outerLineWidth, height: bounds.height - cornerButtonHeight * 2)
                break
            }
            
            line.frame = lineFrame
        }
        
        // 四个角
        let corners = [topLeftCornerLines, topRightCornerLines, bottomLeftCornerLines, bottomRightCornerLines]
        for i in 0..<corners.count {
            let corner = corners[i]
            
            let horizontalFrame: CGRect
            let verticalFrame: CGRect
            let buttonFrame: CGRect
            
            switch i {
            // left top
            case 0:
                horizontalFrame = CGRect(x: cornerButtonWidth / 2, y: cornerButtonHeight / 2, width: cornerButtonWidth / 2, height: cornerLineWidth)
                verticalFrame = CGRect(x: cornerButtonWidth / 2, y: cornerButtonHeight / 2, width: cornerLineWidth, height: cornerButtonHeight / 2)
                buttonFrame = CGRect(x: 0, y: 0, width: cornerButtonWidth, height: cornerButtonHeight)
                break
            // right top
            case 1:
                horizontalFrame = CGRect(x: bounds.width - cornerButtonWidth, y: cornerButtonHeight / 2, width: cornerButtonWidth / 2, height: cornerLineWidth)
                verticalFrame = CGRect(x: bounds.width - cornerButtonWidth / 2 - cornerLineWidth, y: cornerButtonHeight / 2, width: cornerLineWidth, height: cornerButtonHeight / 2)
                buttonFrame = CGRect(x: bounds.width - cornerButtonWidth, y: 0, width: cornerButtonWidth, height: cornerButtonHeight)
                break
            // right bottom
            case 2:
                horizontalFrame = CGRect(x: bounds.width - cornerButtonWidth, y: bounds.height - cornerButtonHeight / 2 - cornerLineWidth, width: cornerButtonWidth / 2, height: cornerLineWidth)
                verticalFrame = CGRect(x: bounds.width - cornerButtonHeight / 2 - cornerLineWidth, y: bounds.height - cornerButtonHeight, width: cornerLineWidth, height: cornerButtonHeight / 2)
                buttonFrame = CGRect(x: bounds.width - cornerButtonWidth, y: bounds.height - cornerButtonHeight, width: cornerButtonWidth, height: cornerButtonHeight)
                break
            // left bottom
            default:
                horizontalFrame = CGRect(x: cornerButtonWidth / 2, y: bounds.height - cornerButtonHeight / 2 - cornerLineWidth, width: cornerButtonWidth / 2, height: cornerLineWidth)
                verticalFrame = CGRect(x: cornerButtonWidth / 2, y: bounds.height - cornerButtonHeight, width: cornerLineWidth, height: cornerButtonHeight / 2)
                buttonFrame = CGRect(x: 0, y: bounds.height - cornerButtonHeight, width: cornerButtonWidth, height: cornerButtonHeight)
                break
            }
            
            corner[0].frame = horizontalFrame
            corner[1].frame = verticalFrame
            cornerButtons[i].frame = buttonFrame
        }
        
        // 中间的横竖线
        let rowSpacing = (bounds.height - cornerButtonHeight - outerLineWidth * 2 - innerLineWidth * CGFloat(horizontalLines.count)) / CGFloat(horizontalLines.count + 1)
        let columnSpacing = (bounds.width - cornerButtonWidth - outerLineWidth * 2 - innerLineWidth * CGFloat(verticalLines.count)) / CGFloat(verticalLines.count + 1)

        for (i, line) in horizontalLines.enumerated() {

            let offset = rowSpacing * CGFloat(i + 1) + innerLineWidth * CGFloat(i)
            
            line.frame = CGRect(x: cornerButtonWidth / 2 + outerLineWidth, y: cornerButtonHeight / 2 + outerLineWidth + offset, width: bounds.width - cornerButtonWidth - outerLineWidth * 2, height: innerLineWidth)
            
        }
        
        for (i, line) in verticalLines.enumerated() {

            let offset = columnSpacing * CGFloat(i + 1) + innerLineWidth * CGFloat(i)
            
            line.frame = CGRect(x: cornerButtonWidth / 2 + outerLineWidth + offset, y: cornerButtonHeight / 2 + outerLineWidth, width: innerLineWidth, height: bounds.height - cornerButtonHeight - outerLineWidth * 2)
            
        }
    }
    
    func getCropRect(frame: CGRect) -> CGRect {
        return CGRect(
            x: frame.origin.x + cornerButtonWidth / 2,
            y: frame.origin.y + cornerButtonHeight / 2,
            width: frame.size.width - cornerButtonWidth,
            height: frame.size.height - cornerButtonHeight
        )
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

internal func radians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180 * .pi
}

