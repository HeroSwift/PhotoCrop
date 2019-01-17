
import UIKit

open class PhotoCropConfiguration {
    
    public var finderBorderLineWidth: CGFloat = 1
    public var finderBorderLineColor: UIColor = .white
    
    public var finderCornerLineWidth: CGFloat = 3
    public var finderCornerLineColor: UIColor = .white
    
    public var finderCornerButtonWidth: CGFloat = 44
    public var finderCornerButtonHeight: CGFloat = 44
    
    public var finderMinWidth: CGFloat = 100
    public var finderMinHeight: CGFloat = 100
    
    public var gridLineColor = UIColor.white.withAlphaComponent(0.5)
    public var gridLineWidth = 1 / UIScreen.main.scale
    
    public var overlayAlpha: CGFloat = 0.8
    
    public var cropRatio: CGFloat = 1

    public init() {
        
    }
    
}
