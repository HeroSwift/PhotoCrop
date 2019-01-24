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

    @IBAction func onClick(_ sender: Any) {
        
        let controller = PhotoCropViewController()
        controller.delegate = self
        controller.show(image: UIImage(named: "bg")!, width: 200, height: 200, maxSize: 200 * 1024, quality: 0.5)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        //photoCrop.setImageBitmap(UIImage(named: "bg")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
        
    }


}

extension ViewController: PhotoCropDelegate {
    
    func photoCropDidCancel(_ photoCrop: PhotoCropViewController) {
        photoCrop.dismiss(animated: true, completion: nil)
    }
    
    func photoCropDidSubmit(_ photoCrop: PhotoCropViewController, result: CropFile) {
        photoCrop.dismiss(animated: true, completion: nil)
        print(result)
    }
    
}
