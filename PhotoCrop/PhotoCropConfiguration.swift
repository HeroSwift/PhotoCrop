
import UIKit

open class PhotoCropConfiguration {
    
    public var backgroundColor = UIColor.black
    
    public var finderBorderWidth: CGFloat = 1
    public var finderBorderColor = UIColor.white
    
    public var finderCornerLineWidth: CGFloat = 3
    public var finderCornerLineSize: CGFloat = 22
    public var finderCornerLineColor = UIColor.white
    
    public var finderCornerButtonSize: CGFloat = 60
    
    public var finderMinWidth: CGFloat = 50
    public var finderMinHeight: CGFloat = 50
    
    public var finderMaxWidth: CGFloat = 0
    public var finderMaxHeight: CGFloat = 0
    
    public var gridLineColor = UIColor.white.withAlphaComponent(0.5)
    public var gridLineWidth = 1 / UIScreen.main.scale
    
    public var overlayBlurAlpha: CGFloat = 1
    public var overlayAlphaNormal: CGFloat = 1
    public var overlayAlphaInteractive: CGFloat = 0.2
    
    // 裁剪宽度，单位是像素，必传
    public var cropWidth: CGFloat = 0
    
    // 裁剪高度，单位是像素，必传
    public var cropHeight: CGFloat = 0

    public init() {
        
    }
    
    open func loadImage(imageView: UIImageView, url: String) {
        
    }
    
}
