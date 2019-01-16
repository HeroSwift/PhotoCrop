
import UIKit

class PhotoCropForeground: UIView {
    
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
    
    public override var frame: CGRect {
        didSet {
            updateImagePosition()
        }
    }
    
    lazy var imageView: UIImageView = {
    
        let view = UIImageView()
        addSubview(view)
        
        clipsToBounds = true
        
        return view
        
    }()
    
    private var relativeX: CGFloat = 0
    private var relativeY: CGFloat = 0
    
    func save() {
        let frame = imageView.frame
        relativeX = frame.origin.x / frame.width
        relativeY = frame.origin.y / frame.height
    }
    
    func restore() {
        
        var imageFrame = imageView.frame
        let x = relativeX * imageFrame.width
        let y = relativeY * imageFrame.height
        
        imageFrame.origin = CGPoint(x: x, y: y)
        
        let offsetX = -(x + frame.origin.x)
        let offsetY = -(y + frame.origin.y)
        
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
        
    }

    func updateImagePosition() {
        
        guard let scrollView = scrollView else {
            return
        }
        
        let contentOffset = scrollView.contentOffset
        print("position: \(contentOffset)")
        // contentOffset 是反向的，比如往右下方拖拽，contentOffset 的 x 和 y 都是负数
        // 并且，x 和 y 的绝对值是到 UIScrollView 左上角的距离
        
        imageView.frame.origin = CGPoint(x: -contentOffset.x - frame.origin.x, y: -contentOffset.y - frame.origin.y)
        
    }
    
    func updateImageSize() {
        
        print("size: \(scrollView.contentSize)")
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
