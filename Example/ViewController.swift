//
//  ViewController.swift
//  Example
//
//  Created by zhujl on 2018/9/16.
//  Copyright © 2018年 finstao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let photoCrop = PhotoCrop()
        photoCrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoCrop)
        
        let button = SimpleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("rotate", for: .normal)
        button.onClick = {
            photoCrop.rotate()
        }
        view.addSubview(button)
        
        view.addConstraints([
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
        ])
        
        
        
        view.backgroundColor = .gray

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

