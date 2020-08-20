//
//  OpenCVWrapper.m
//  RecognitionImage
//
//  Created by 羊小咩 on 2020/8/18.
//  Copyright © 2020 咩橘客. All rights reserved.
//
#include "OpenCVHeader.h"
#import "OpenCVWrapper.h"

//啟用命名空間
using namespace cv;
using namespace std;

@implementation OpenCVWrapper

+ (NSString *) test_c{
    char str[]="Hello C++";
    std::cout << str << std::endl;
    return [NSString stringWithUTF8String:str];
}

+ (NSString *) cv_version{
    
    cout << "OpenCV version : " << CV_VERSION << endl;
    char str[]= CV_VERSION;
    return [NSString stringWithUTF8String:str];
    
}

@end
