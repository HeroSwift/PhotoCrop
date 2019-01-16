
import UIKit

class PhotoCropOverlay: UIView {

    override var frame: CGRect {
        didSet {
            guard frame.width != oldValue.width || frame.height != oldValue.height else {
                return
            }
            update()
        }
    }

    private lazy var blueEffectView: UIVisualEffectView = {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.alpha = 0.8
        
        insertSubview(view, at: 0)

        return view
        
    }()
    
    // 无视各种交互
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    private func update() {
        
        blueEffectView.frame = bounds
        
    }

}
