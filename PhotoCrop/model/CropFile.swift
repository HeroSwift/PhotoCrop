
import UIKit

public class CropFile {
    
    public let path: String
    public let size: Int
    public let width: CGFloat
    public let height: CGFloat
    
    init(path: String, size: Int, width: CGFloat, height: CGFloat) {
        self.path = path
        self.size = size
        self.width = width
        self.height = height
    }
    
}
