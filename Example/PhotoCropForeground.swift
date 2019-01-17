
import UIKit

// 没法在 Overlay 上实现打孔 + 动画
// 因此只好新建一个 View，用 clipsToBounds + imageView 的位移来实现
// 这个 view 需要跟 UIScrollView 紧密绑定，当 UIScrollView 滑动时，也要移动 imageView
// 从而实现视觉上的合二为一
class PhotoCropForeground: UIView {
    
    public override var frame: CGRect {
        didSet {
            updateImagePosition()
        }
    }
    
    var scaleFactor: CGFloat = 0 {
        didSet {
            guard scaleFactor != oldValue else {
                return
            }
            onScaleFactorChange()
        }
    }
    
    var onScaleFactorChange: (() -> Void)!
    
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
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    private lazy var imageView: UIImageView = {
    
        let view = UIImageView()
        addSubview(view)
        
        clipsToBounds = true
        
        return view
        
    }()
    
    private var relativeX: CGFloat = 0
    private var relativeY: CGFloat = 0
    
    // 记录图片的当前位置
    func save() {
        
        let imageFrame = imageView.frame
        
        relativeX = imageFrame.origin.x / imageFrame.width
        relativeY = imageFrame.origin.y / imageFrame.height
        
    }
    
    // 当 UIScrollView 发生改变后，再把记录的相对位置还原回去
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

        // contentOffset 是反向的，比如往右下方拖拽，contentOffset 的 x 和 y 都是负数
        // 并且，x 和 y 的绝对值是到 UIScrollView 左上角的距离
        
        imageView.frame.origin = CGPoint(
            x: -contentOffset.x - frame.origin.x,
            y: -contentOffset.y - frame.origin.y
        )
        
    }
    
    func updateImageSize() {
        
        imageView.frame.size = scrollView.contentSize
        
        scaleFactor = scrollView.maximumZoomScale / scrollView.zoomScale

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
    
    // 无视各种交互
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}
