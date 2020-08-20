//
//  OpenCVHeader.h
//  InvoiceRecognition
//
//  Created by 羊小咩 on 2020/4/21.
//  Copyright © 2020 羊小咩. All rights reserved.
//

#ifndef OpenCVHeader_h
#define OpenCVHeader_h

/*
 
 导入头文件的深坑
 导入#import <opencv2/opencv.hpp>报Expected identitier的错误。这是由于opencv 的 import 要写在#import <UIKit/UIKit.h>、#import <Foundation/Foundation.h>这些系统自带的 framework 前面，否则会出现重命名的冲突。
 导入OpenCV使用时，Xcode8会有一堆类似warning: empty paragraph passed to '@param' command [-Wdocumentation]的文档警告。
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#pragma clang pop

#endif /* OpenCVHeader_h */
