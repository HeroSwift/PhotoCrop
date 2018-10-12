
import UIKit

public class PhotoCrop: UIView {
    
    // 旋转容器
    let rotateView = UIView()
    
    // 图片容器，可缩放
    let scrollView = PhotoCropScrollView()
    
    // 旋转角度
    var angle = 0.0
    
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
    
    public func rotate(duration: TimeInterval = 0.3, options: UIViewAnimationOptions = .curveEaseInOut) {
        
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
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
        
    }
    
}



