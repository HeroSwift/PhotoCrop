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
        
        let photoCrop = PhotoCrop(frame: CGRect(x: 50, y: 100, width: 300, height: 300))
        photoCrop.backgroundColor = .red
        view.addSubview(photoCrop)
        
        view.backgroundColor = .gray

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

