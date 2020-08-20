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


}

