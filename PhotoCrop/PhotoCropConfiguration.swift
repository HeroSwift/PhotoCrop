
import UIKit

open class PhotoCropConfiguration {
    
    public var backgroundColor = UIColor.black
    
    public var finderBorderWidth: CGFloat = 1
    public var finderBorderColor = UIColor.white
    
    public var finderCornerLineWidth: CGFloat = 3
    public var finderCornerLineSize: CGFloat = 22
    public var finderCornerLineColor = UIColor.white
    
    public var finderCornerButtonSize: CGFloat = 60
    
    public var finderMinWidth: CGFloat = 60
    public var finderMinHeight: CGFloat = 60
    
    public var finderMaxWidth: CGFloat = 0
    public var finderMaxHeight: CGFloat = 0
    
    public var gridLineColor = UIColor.white.withAlphaComponent(0.5)
    public var gridLineWidth = 1 / UIScreen.main.scale
    
    public var overlayBlurAlpha: CGFloat = 1
    public var overlayAlphaNormal: CGFloat = 1
    public var overlayAlphaInteractive: CGFloat = 0.2
    
    // 裁剪宽度
    public var cropWidth: CGFloat = 0
    
    // 裁剪高度
    public var cropHeight: CGFloat = 0
    
    // 裁剪后图片的最大尺寸
    public var maxSize = 200 * 1024
    
    // 裁剪后图片如果大于 maxSize，压缩图片的质量
    public var quality: CGFloat = 0.5

    public init() {
        
    }
    
}
