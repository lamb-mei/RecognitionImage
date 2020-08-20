//
//  ViewController.swift
//  RecognitionImage
//
//  Created by 羊小咩 on 2020/8/17.
//  Copyright © 2020 咩橘客. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let t = OpenCVWrapper.test_c()
        print("c++ \(t)")
        print("cv_version: \(OpenCVWrapper.cv_version())")
        
    }
    
    @IBAction func findC(_ sender: Any) {
        let image = UIImage(named: "IMG_1415.JPG")
        let detecteBlurRes = Recognition.detecteBlur(image!)
        print("isBlur:\(detecteBlurRes.isBlur) variance:\(detecteBlurRes.variance)")
        let res = Recognition.findCircles(image!)
        
        let vc = WithImagesViewController()
        vc.images = res.preprocess
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        
    }
    @IBAction func findF(_ sender: Any) {
        
        let image = UIImage(named: "IMG_1415.JPG")

        let res = Recognition.findFeature(image!)
        
        let vc = WithImagesViewController()
        vc.images = res.preprocess
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

