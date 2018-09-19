
import UIKit

class PhotoCropScrollView: UIScrollView {
    
    let photoView = UIImageView()
    
    var photo: UIImage! {
        didSet {
            
            zoomScale = 1
       
            photoView.image = photo
            photoView.frame.size = photo.size
            
            contentSize = photo.size
        }
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
        
        // min 和 max 必须不一样，否则不能缩放
        // 最大不能超过图片自身的尺寸，否则会模糊
        // 最小则需要计算
        maximumZoomScale = 1
        
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        addSubview(photoView)
        
    }
    
}
