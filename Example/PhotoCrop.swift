
import UIKit

public class PhotoCrop: UIView {
    
    // 旋转容器
    let rotateView = UIView()
    
    // 图片容器，可缩放
    let scrollView = PhotoCropScrollView()
    
    // 裁剪器
    let cropOverlay = PhotoCropOverlay()
    
    // 旋转角度
    var angle = 0.0
    
    // 是否正在动画中
    var isAnimating = false
    
    private var currentRect: CGRect {
        return CGRect(
            origin: .zero,
            size: angle.truncatingRemainder(dividingBy: Double.pi) == 0
                ? frame.size
                : CGSize(width: frame.size.height, height: frame.size.width)
        )
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

        backgroundColor = .blue
        
        rotateView.backgroundColor = .green
        
        addSubview(rotateView)
        
        scrollView.backgroundColor = .red
        scrollView.photo = UIImage(named: "bg")
        
        rotateView.addSubview(scrollView)
        
    }
    
    public override func layoutSubviews() {
        
        // rotateView 填满本视图
        rotateView.frame = CGRect(origin: .zero, size: frame.size)
        
        // 这句很重要
        // 根据当前的旋转角度设置 frame
        scrollView.frame = currentRect
        
        scrollView.updateFrame()
        
        print("layoutSubviews: \(frame) \(rotateView.frame) \(scrollView.frame)")
        
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
    
    public func showCropOverlay(animationDuration: TimeInterval = 0.3, options: UIView.AnimationOptions = .curveEaseInOut) {
        
        cropOverlay.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        rotateView.addSubview(cropOverlay)
        
        
        
        let animations: () -> Void = {
            self.scrollView.updateFrame()
            self.scrollView.contentOffset = CGPoint(x: -self.cropOverlay.cornerButtonWidth, y: -self.cropOverlay.cornerButtonHeight)
        }
        
        let completion: (Bool) -> Void = { finished in
            
        }
        
        animate(animationDuration: animationDuration, options: options, animations: animations, completion: completion)
        
    }
    
    public func hideCropOverlay() {
        
        cropOverlay.removeFromSuperview()
        
    }
    
    private func center() {
        
        
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



