
import UIKit

class PhotoCropImageView: UIView {
    
    var scrollView: UIScrollView! {
        didSet {
            
            guard scrollView !== oldValue else {
                return
            }
            
            if oldValue != nil {
                oldValue.removeObserver(self, forKeyPath: "contentSize", context: nil)
                oldValue.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            }
            
            scrollView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
            
            updateImagePosition()
            updateImageSize()
            
        }
    }
    
    lazy var imageView: UIImageView = {
    
        let view = UIImageView()
        addSubview(view)
        
        clipsToBounds = true
        
        return view
        
    }()

    func updateImagePosition() {
        
        let contentOffset = scrollView.contentOffset
        
        // contentOffset 是反向的，比如往右下方拖拽，contentOffset 的 x 和 y 都是负数
        // 并且，x 和 y 的绝对值是到 UIScrollView 左上角的距离
        
        imageView.frame.origin = CGPoint(x: -contentOffset.x - frame.origin.x, y: -contentOffset.y - frame.origin.y)
        
    }
    
    func updateImageSize() {
        
        imageView.frame.size = scrollView.contentSize
        
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case "contentSize":
            updateImageSize()
            break
            
        case "contentOffset":
            updateImagePosition()
            break
        default: ()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}
