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

    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        view.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        return imageView
        
    }()
    
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
            self.photoCrop.image = image
            self.photoCrop.isCropping = false
        }
        view.addSubview(button)
        
        let showButton = SimpleButton()
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.setTitle("show", for: .normal)
        showButton.onClick = {
            self.photoCrop.isCropping = true
        }
        view.addSubview(showButton)
        
        let hideButton = SimpleButton()
        hideButton.translatesAutoresizingMaskIntoConstraints = false
        hideButton.setTitle("hide", for: .normal)
        hideButton.onClick = {
            self.photoCrop.isCropping = false
        }
        view.addSubview(hideButton)
        
        view.addConstraints([
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: showButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: showButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: hideButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: hideButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        
        
        view.backgroundColor = .gray

    }
    
    override func viewDidLayoutSubviews() {
        photoCrop.image = UIImage(named: "bg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

