
import UIKit

public class PhotoCropViewController: UIViewController {
    
    public var delegate: PhotoCropDelegate!
    
    private var photoCrop: PhotoCrop!
    
    private var image: UIImage!
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private var maxSize: Int = 0
    private var quality: CGFloat = 0
    
    private var bottomLayoutConstraint: NSLayoutConstraint!
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public func show(image: UIImage, width: CGFloat, height: CGFloat, maxSize: Int, quality: CGFloat) {
        
        self.image = image
        self.width = width
        self.height = height
        self.maxSize = maxSize
        self.quality = quality
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        let configuration = PhotoCropConfiguration()
        configuration.cropWidth = width
        configuration.cropHeight = height
        
        photoCrop = PhotoCrop(configuration: configuration)
        
        photoCrop.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(photoCrop)
        view.backgroundColor = .black
        
        view.addConstraints([
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        let buttonFont = UIFont.systemFont(ofSize: 15)
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 50
        
        let cropButton = SimpleButton()
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        cropButton.setTitle("确定", for: .normal)
        cropButton.titleLabel?.font = buttonFont
        cropButton.onClick = {
            guard let image = self.photoCrop.crop() else {
                return
            }
            guard let file = self.photoCrop.save(image: image) else {
                return
            }
            let result = self.photoCrop.compress(source: file, maxSize: self.maxSize, quality: self.quality)
            self.delegate.photoCropDidSubmit(self, result: result)
        }

        let resetButton = SimpleButton()
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("重置", for: .normal)
        resetButton.titleLabel?.font = buttonFont
        resetButton.onClick = {
            self.photoCrop.reset()
        }
        
        let cancelButton = SimpleButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = buttonFont
        cancelButton.onClick = {
            self.delegate.photoCropDidCancel(self)
        }
        
        let bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(cropButton)
        bottomBar.addSubview(resetButton)
        bottomBar.addSubview(cancelButton)
        
        view.addSubview(bottomBar)
        
        bottomLayoutConstraint = NSLayoutConstraint(item: bottomBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([
            
            NSLayoutConstraint(item: bottomBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            bottomLayoutConstraint,
            
            
            NSLayoutConstraint(item: cropButton, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cropButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cropButton, attribute: .right, relatedBy: .equal, toItem: bottomBar, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: cropButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: cropButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            
            NSLayoutConstraint(item: resetButton, attribute: .centerY, relatedBy: .equal, toItem: cropButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .centerX, relatedBy: .equal, toItem: bottomBar, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: cropButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: bottomBar, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
        ])
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            bottomLayoutConstraint.constant = -view.safeAreaInsets.bottom
            view.setNeedsLayout()
        }
        
        photoCrop.setImageBitmap(image)
        photoCrop.isCropping = true
    }
    
}
