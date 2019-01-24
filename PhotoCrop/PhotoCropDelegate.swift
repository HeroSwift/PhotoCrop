
import UIKit

public protocol PhotoCropDelegate {
    
    // 点击取消按钮
    func photoCropDidCancel(_ photoCrop: PhotoCropViewController)
    
    // 点击确定按钮
    func photoCropDidSubmit(_ photoCrop: PhotoCropViewController, result: CropFile)

}
