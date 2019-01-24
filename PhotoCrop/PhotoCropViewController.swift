
import UIKit

public class PhotoCropViewController: UIViewController {
    
    public var delegate: PhotoCropDelegate!
    public var configuration: PhotoCropConfiguration!
    
    public var loadImage: ((String, (UIImage?) -> Void) -> Void)!
    
    private var photoCrop: PhotoCrop!
    
    private var url: String!

    private var bottomLayoutConstraint: NSLayoutConstraint!
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public func show(url: String) {
        
        self.url = url
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
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
        
        let buttonTextFont = UIFont.systemFont(ofSize: 15)
        let buttonTextColor = UIColor.white
        
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 50
        
        let cancelButton = SimpleButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(buttonTextColor, for: .normal)
        cancelButton.titleLabel?.font = buttonTextFont
        cancelButton.onClick = {
            self.delegate.photoCropDidCancel(self)
        }

        let resetButton = SimpleButton()
        resetButton.isHidden = true
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("重置", for: .normal)
        resetButton.setTitleColor(buttonTextColor, for: .normal)
        resetButton.titleLabel?.font = buttonTextFont
        resetButton.onClick = {
            self.photoCrop.reset()
        }
        
        let cropButton = SimpleButton()
        cropButton.isHidden = true
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        cropButton.setTitle("确定", for: .normal)
        cropButton.setTitleColor(buttonTextColor, for: .normal)
        cropButton.titleLabel?.font = buttonTextFont
        cropButton.onClick = {
            guard let image = self.photoCrop.crop() else {
                return
            }
            guard let file = self.photoCrop.save(image: image) else {
                return
            }
            let result = self.photoCrop.compress(source: file)
            self.delegate.photoCropDidSubmit(self, cropFile: result)
        }
        
        
        let bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(cancelButton)
        bottomBar.addSubview(resetButton)
        bottomBar.addSubview(cropButton)
        
        view.addSubview(bottomBar)
        
        bottomLayoutConstraint = NSLayoutConstraint(item: bottomBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([
            
            NSLayoutConstraint(item: bottomBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            bottomLayoutConstraint,

            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: bottomBar, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            NSLayoutConstraint(item: resetButton, attribute: .centerY, relatedBy: .equal, toItem: cropButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .centerX, relatedBy: .equal, toItem: bottomBar, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            NSLayoutConstraint(item: cropButton, attribute: .centerY, relatedBy: .equal, toItem: cropButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cropButton, attribute: .right, relatedBy: .equal, toItem: bottomBar, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: cropButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: cropButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),

        ])
        
        loadImage(url) { image in
            
            guard let image = image else {
                return
            }
            self.photoCrop.image = image
            
            resetButton.isHidden = false
            cropButton.isHidden = false
            
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startCropping), userInfo: nil, repeats: false)
            
        }
        
    }
    
    @objc private func startCropping() {
        photoCrop.isCropping = true
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            bottomLayoutConstraint.constant = -view.safeAreaInsets.bottom
            view.setNeedsLayout()
        }
        
    }
    
}
