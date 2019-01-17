
import UIKit

class PhotoCropArea {
    
    static let zero = PhotoCropArea(top: 0, left: 0, bottom: 0, right: 0)
    
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat
    
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
