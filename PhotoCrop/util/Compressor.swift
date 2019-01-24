
import UIKit

public class Compressor {
    
    private var maxWidth: CGFloat = 3000
    
    private var maxHeight: CGFloat = 3000
    
    // 最大 200KB
    private var maxSize: Int = 200 * 1024
    
    private var quality: CGFloat = 0.5
    
    public init(maxWidth: CGFloat, maxHeight: CGFloat, maxSize: Int, quality: CGFloat) {
        
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.maxSize = maxSize
        self.quality = quality
        
    }
    
    public init(maxSize: Int, quality: CGFloat) {
        
        self.maxSize = maxSize
        self.quality = quality
        
    }
    
    // 尽可能的缩小文件大小
    public func compress(source: CropFile) -> CropFile {
        
        if source.size < maxSize {
            return source
        }
        
        guard var image = UIImage(contentsOfFile: source.path) else {
            return source
        }
        
        var width = source.width
        var height = source.height

        let ratio = height > 0 ? width / height : 1
        
        // 是否需要缩放
        var scaled = false
        
        if width > maxWidth && height > maxHeight {
            scaled = true
            // 看短边
            if width / maxWidth > height / maxHeight {
                height = maxHeight
                width = height * ratio
            }
            else {
                width = maxWidth
                height = width / ratio
            }
        }
        else if width > maxWidth && height <= maxHeight {
            scaled = true
            width = maxWidth
            height = width / ratio
        }
        else if width <= maxWidth && height > maxHeight {
            scaled = true
            height = maxHeight
            width = height * ratio
        }

        if scaled {
            image = Util.shared.createNewImage(image: image, size: CGSize(width: width, height: height), scale: 1)
            // 缩放之后看下体积有没控制住
            if let file = Util.shared.createNewFile(image: image, quality: 1), file.size < maxSize {
                return file
            }
        }
        
        // 没辙，听天由命吧
        return Util.shared.createNewFile(image: image, quality: quality) ?? source
        
    }
    
    // 指定输出尺寸
    public func compress(source: CropFile, width: CGFloat, height: CGFloat) -> CropFile {
        
        guard source.width != width || source.height != height else {
            return source
        }
        
        guard var image = UIImage(contentsOfFile: source.path) else {
            return source
        }
        
        image = Util.shared.createNewImage(image: image, size: CGSize(width: width, height: height), scale: 1)
        
        var result = Util.shared.createNewFile(image: image, quality: 1)
        if let file = result, file.size > maxSize {
            result = Util.shared.createNewFile(image: image, quality: quality)
        }
        
        return result ?? source
        
    }
    
}
