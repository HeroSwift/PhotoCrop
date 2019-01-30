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
        let configuration = PhotoCropConfiguration()
        configuration.cropWidth = 200
        configuration.cropHeight = 200
        
        controller.delegate = self
        controller.configuration = configuration
        
        PhotoCropViewController.loadImage = { url, callback in
            callback(UIImage(named: "bg"))
        }
        
        controller.show(url: "123123")
        
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
    
    func photoCropDidSubmit(_ photoCrop: PhotoCropViewController, cropFile: CropFile) {
        photoCrop.dismiss(animated: true, completion: nil)
        print(cropFile)
    }
    
}
