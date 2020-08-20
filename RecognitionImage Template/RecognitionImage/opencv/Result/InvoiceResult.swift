//
//  OpenCVResult.swift
//  InvoiceRecognition
//
//  Created by 羊小咩 on 2020/5/20.
//  Copyright © 2020 羊小咩. All rights reserved.
//

import UIKit

@objcMembers public class InvoiceResult: NSObject {
    private(set) var orgi_size:CGSize // 原始相片的大小
    private(set) var size:CGSize // 處理相片的大小
    private(set) var proportion:Float
    required public init(orgi_size: CGSize , size:CGSize) {
        if size.height != 0 {
            proportion = Float(size.height / orgi_size.height)
        }else{
            proportion = 0
        }
        
        self.orgi_size = orgi_size
        self.size = size
        
        super.init()
    }
    
    //放置預處理圖片
    public var preprocess:[UIImage] = []
    public var result:[FindItem]?
}



@objcMembers
public class FindItem: NSObject {
//    public var center:CGPoint
//    public var angle:Float
    
    public var tl:CGPoint //top left
    public var size:CGSize
    
    public var orgi_img:UIImage
    public var thresholds:[UIImage] = []
    
    
    required public init(tl:CGPoint , size:CGSize , orgi_img img:UIImage) {
        self.tl = tl
        self.size = size
        self.orgi_img = img
        super.init()
    }
    
//    required public init(center:CGPoint , size:CGSize , angle:Float , orgi_img img:UIImage) {
//        self.center = center
//        self.size = size
//        self.angle = angle
//        self.orgi_img = img
//        super.init()
//    }

}
