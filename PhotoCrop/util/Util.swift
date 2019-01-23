
import Foundation

class Util {
    
    static let shared = Util()
    
    private init() {
        
    }
    
    func getFilePath(dirname: String, extname: String) -> String {
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dirname) {
            try? fileManager.createDirectory(atPath: dirname, withIntermediateDirectories: true, attributes: nil)
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        
        let filename = "\(format.string(from: Date()))\(extname)"
        
        if dirname.hasSuffix("/") {
            return dirname + filename
        }
        
        return "\(dirname)/\(filename)"
        
    }
}
