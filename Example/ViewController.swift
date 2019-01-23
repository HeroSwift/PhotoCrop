//
//  ViewController.swift
//  Example
//
//  Created by zhujl on 2018/9/16.
//  Copyright © 2018年 finstao. All rights reserved.
//

import UIKit
import PhotoCrop

class ViewController: UIViewController {

    let photoCrop = PhotoCrop(configuration: PhotoCropConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        photoCrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoCrop)
        
        let button = SimpleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("rotate", for: .normal)
        button.onClick = {
            let image = self.photoCrop.crop()
            self.photoCrop.setImageBitmap(image!)
            self.photoCrop.isCropping = false
        }
        view.addSubview(button)
        
        let toggleButton = SimpleButton()
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.setTitle("Toggle", for: .normal)
        toggleButton.onClick = {
            self.photoCrop.isCropping = !self.photoCrop.isCropping
        }
        view.addSubview(toggleButton)
        
        let hideButton = SimpleButton()
        hideButton.translatesAutoresizingMaskIntoConstraints = false
        hideButton.setTitle("Rotate", for: .normal)
        hideButton.onClick = {
            self.photoCrop.reset()
        }
        view.addSubview(hideButton)
        
        view.addConstraints([
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: toggleButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: toggleButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: hideButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: hideButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        
        
        view.backgroundColor = .black

    }
    
    override func viewDidLayoutSubviews() {
        photoCrop.setImageBitmap(UIImage(named: "bg")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

