
import UIKit

public class PhotoCropFinder: UIView {
    
    var configuration: PhotoCropConfiguration!
    
    var onCropAreaChange: ((PhotoCropArea) -> Void)!
    var onCropAreaResize: (() -> Void)!
    
    public override var frame: CGRect {
        didSet {
            size = frame.size
        }
    }
    
    var cropArea = PhotoCropArea.zero {
        didSet {
            update()
            onCropAreaChange(cropArea)
        }
    }
    
    var normalizedCropArea = PhotoCropArea.zero
    
    private var minWidth: CGFloat = 0
    private var minHeight: CGFloat = 0
    
    private lazy var topBorder: UIView = {
        return createLine(color: configuration.finderBorderColor)
    }()
    
    private lazy var rightBorder: UIView = {
        return createLine(color: configuration.finderBorderColor)
    }()
    
    private lazy var bottomBorder: UIView = {
        return createLine(color: configuration.finderBorderColor)
    }()
    
    private lazy var leftBorder: UIView = {
        return createLine(color: configuration.finderBorderColor)
    }()
    
    private lazy var topLeftButton: UIView = {
        return createButton()
    }()
    
    private lazy var topRightButton: UIView = {
        return createButton()
    }()
    
    private lazy var bottomLeftButton: UIView = {
        return createButton()
    }()
    
    private lazy var bottomRightButton: UIView = {
        return createButton()
    }()

    private lazy var topLeftHorizontalLine: UIView = {
        return createHorizontalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var topLeftVerticalLine: UIView = {
        return createVerticalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var topRightHorizontalLine: UIView = {
        return createHorizontalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var topRightVerticalLine: UIView = {
        return createVerticalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var bottomLeftHorizontalLine: UIView = {
        return createHorizontalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var bottomLeftVerticalLine: UIView = {
        return createVerticalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var bottomRightHorizontalLine: UIView = {
        return createHorizontalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private lazy var bottomRightVerticalLine: UIView = {
        return createVerticalCornerLine(color: configuration.finderCornerLineColor)
    }()
    
    private var resizeCropAreaTimer: Timer?
    
    private var size = CGSize.zero {
        didSet {
            
            guard size.width != oldValue.width || size.height != oldValue.height else {
                return
            }
            
            let cropWidth = size.width - configuration.finderCornerButtonSize - 2 * configuration.finderCornerLineWidth
            let cropHeight = cropWidth / configuration.cropRatio
            
            let top = (size.height - cropHeight) / 2
            let left = configuration.finderCornerButtonSize / 2 + configuration.finderCornerLineWidth
            
            normalizedCropArea = PhotoCropArea(top: top, left: left, bottom: top, right: left)
        
            // 重新计算裁剪区域
            resizeCropArea()
            
        }
    }
    
    @objc private func resize(gestureRecognizer: UIPanGestureRecognizer) {
        
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
        
        // 裁剪区域
        var left = cropArea.left
        var top = cropArea.top
        
        var right = viewWidth - cropArea.right
        var bottom = viewHeight - cropArea.bottom
        
        let maxLeft = normalizedCropArea.left
        let maxRight = viewWidth - normalizedCropArea.right
        
        switch button {
        case topLeftButton:
            left = min(right - minWidth, max(maxLeft, left + transX))
            top = bottom - (right - left) / configuration.cropRatio
            break
        case topRightButton:
            right = min(maxRight, max(left + minWidth, right + transX))
            top = bottom - (right - left) / configuration.cropRatio
            break
        case bottomRightButton:
            right = min(maxRight, max(left + minWidth, right + transX))
            bottom = top + (right - left) / configuration.cropRatio
            break
        default:
            left = min(right - minWidth, max(maxLeft, left + transX))
            bottom = top + (right - left) / configuration.cropRatio
            break
        }
        
        cropArea = PhotoCropArea(top: top, left: left, bottom: viewHeight - bottom, right: viewWidth - right)
        
        gestureRecognizer.setTranslation(.zero, in: self)
        
    }
    
    func updateMinSize(scaleFactor: CGFloat, minWidth: CGFloat, minHeight: CGFloat) {
        
        let rect = normalizedCropArea.toRect(rect: self.bounds)
        
        self.minWidth = max(rect.width / scaleFactor, minWidth)
        self.minHeight = max(rect.height / scaleFactor, minHeight)

    }
    
    @objc private func resizeCropArea() {
        removeResizeCropAreaTimer()
        onCropAreaResize()
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
        if topLeftButton === view
            || topRightButton === view
            || bottomLeftButton === view
            || bottomRightButton === view
        {
            return view
        }
        
        return nil
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
        line.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerLineSize, height: configuration.finderCornerLineWidth)
        return line
    }
    
    private func createVerticalCornerLine(color: UIColor) -> UIView {
        let line = createLine(color: color)
        line.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerLineWidth, height: configuration.finderCornerLineSize)
        return line
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        button.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerButtonSize, height: configuration.finderCornerButtonSize)
        button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(resize)))
        addSubview(button)
        return button
    }
    
    private func update() {
        
        let left = cropArea.left
        let top = cropArea.top
        let right = size.width - cropArea.right
        let bottom = size.height - cropArea.bottom
        
        let halfButtonSize = configuration.finderCornerButtonSize / 2
        
        topBorder.frame = CGRect(x: left, y: top - configuration.finderBorderWidth, width: right - left, height: configuration.finderBorderWidth)
        rightBorder.frame = CGRect(x: right, y: top, width: configuration.finderBorderWidth, height: bottom - top)
        bottomBorder.frame = CGRect(x: left, y: bottom, width: right - left, height: configuration.finderBorderWidth)
        leftBorder.frame = CGRect(x: left - configuration.finderBorderWidth, y: top, width: configuration.finderBorderWidth, height: bottom - top)

        topLeftButton.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth - halfButtonSize, y: top - configuration.finderCornerLineWidth - halfButtonSize)
        topLeftHorizontalLine.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth, y: top - configuration.finderCornerLineWidth)
        topLeftVerticalLine.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth, y: top - configuration.finderCornerLineWidth)
        
        topRightButton.frame.origin = CGPoint(x: right + configuration.finderCornerLineWidth - halfButtonSize, y: top - configuration.finderCornerLineWidth - halfButtonSize)
        topRightHorizontalLine.frame.origin = CGPoint(x: right + configuration.finderCornerLineWidth - configuration.finderCornerLineSize, y: top - configuration.finderCornerLineWidth)
        topRightVerticalLine.frame.origin = CGPoint(x: right, y: top - configuration.finderCornerLineWidth)
        
        bottomRightButton.frame.origin = CGPoint(x: right + configuration.finderCornerLineWidth - halfButtonSize, y: bottom + configuration.finderCornerLineWidth - halfButtonSize)
        bottomRightHorizontalLine.frame.origin = CGPoint(x: right + configuration.finderCornerLineWidth - configuration.finderCornerLineSize, y: bottom)
        bottomRightVerticalLine.frame.origin = CGPoint(x: right, y: bottom + configuration.finderCornerLineWidth - configuration.finderCornerLineSize)
        
        bottomLeftButton.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth - halfButtonSize, y: bottom + configuration.finderCornerLineWidth - halfButtonSize)
        bottomLeftHorizontalLine.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth, y: bottom)
        bottomLeftVerticalLine.frame.origin = CGPoint(x: left - configuration.finderCornerLineWidth, y: bottom + configuration.finderCornerLineWidth - configuration.finderCornerLineSize)
        
    }
    
}

