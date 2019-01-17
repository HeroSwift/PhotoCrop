
import UIKit

open class PhotoCropConfiguration {
    
    public var finderBorderWidth: CGFloat = 1
    public var finderBorderColor: UIColor = .white
    
    public var finderCornerLineWidth: CGFloat = 3
    public var finderCornerLineSize: CGFloat = 22
    public var finderCornerLineColor: UIColor = .white
    
    public var finderCornerButtonSize: CGFloat = 44
    
    public var finderMinWidth: CGFloat = 100
    public var finderMinHeight: CGFloat = 100
    
    public var gridLineColor = UIColor.white.withAlphaComponent(0.5)
    public var gridLineWidth = 1 / UIScreen.main.scale
    
    public var overlayAlpha: CGFloat = 0.8
    
    public var cropRatio: CGFloat = 1

    public init() {
        
    }
    
}
