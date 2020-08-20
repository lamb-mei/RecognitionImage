//
//  Recognition.m
//  RecognitionInvoice
//
//  Created by 羊小咩 on 2020/7/9.
//  Copyright © 2020 咩橘客. All rights reserved.
//
#include "OpenCVHeader.h"
#import "Recognition.h"
#import "RecognitionImage-Swift.h"

using namespace cv;
using namespace std;

@implementation Recognition


// MARK: - Common
//修正 Exif 轉向
+(UIImage *) fixedOrientation:(UIImage *) image {
    
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default: break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            CGAffineTransformTranslate(transform, image.size.width, 0);
            CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            CGAffineTransformTranslate(transform, image.size.height, 0);
            CGAffineTransformScale(transform, -1, 1);
            break;
            
        default: break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(nil, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
    
    CGContextConcatCTM(ctx, transform);
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    
    return [UIImage imageWithCGImage:cgImage];
}


// MARK: - Detecte Blur
std::tuple<bool, double> detecte_blur(cv::Mat& m ,  double threshold = 100){
    cv::Mat gray;
    cv::cvtColor(m, gray, CV_BGRA2GRAY);
    cv::Mat laplacianImage;
    cv::Laplacian(gray, laplacianImage, CV_64F);
    
    //meanStdDev：
    //計算矩陣的均值和標準偏差 (方差）
    cv::Scalar mean, stddev; // 0:1st channel, 1:2nd channel and 2:3rd channel
    meanStdDev(laplacianImage, mean, stddev, Mat());
    double variance = stddev.val[0] * stddev.val[0];
    //
    //        double threshold = 100;
//    NSLog(@"detecte_blur variance :%.02f  %.02f",variance ,threshold );
    bool isBlur = false;
    if (variance <= threshold) {
        // Blurry
        isBlur = true;

    } else {
        // Not blurry
    }
    
//        C++ 11
//    https://stackoverflow.com/questions/321068/returning-multiple-values-from-a-c-function
//    return  std::make_tuple(isBlur, variance);
//C++ 17
    return {isBlur,variance};
}


+ (DetecteBlurResult *) detecteBlur:(UIImage *) image{
    return [[self class] detecteBlur:image threshold:100];
}

+ (DetecteBlurResult *) detecteBlur:(UIImage *) image threshold:(double)threshold{
    cv::Mat imageMat_Orig;
    UIImageToMat(image, imageMat_Orig);
        //    C++ 11
        //    bool isblur;
        //    double variance;
        //    tie(isblur, variance) = detecte_blur(imageMat_Orig);
        //    C++ 17
    auto [isblur, variance] = detecte_blur(imageMat_Orig , threshold);
        //    NSDictionary<NSString*, NSString*>* dict = @{@"isblur":@(isblur) , @"variance":@(variance)};
        //    NSDictionary* dict = @{@"isblur":@(isblur) , @"variance":@(variance)};
    double v = (double) variance;
    DetecteBlurResult *res = [[DetecteBlurResult alloc] initWithAttributes:isblur variance:v];
    return res;
}

// MARK: - Recognition


//偏斜校正＋修剪
Mat deskewAndCrop(Mat input, const RotatedRect& box)
{
    double angle = box.angle;
    Size2f size = box.size;
    
    if(angle < -45){
        angle += 90;
        std::swap(size.width ,size.height);
    }
    Mat transform = getRotationMatrix2D(box.center, angle, 1.0);
    Mat rotated;
    warpAffine(input, rotated, transform, input.size(),INTER_CUBIC);
    
    //  getRectSubPix 只支援的單通道或三通道 因此需要轉換
    if(rotated.channels() == 4){
        cvtColor(rotated,rotated,CV_RGBA2RGB);
    }
//    NSLog(@"depth:%d  channels:%d " , input.depth() , input.channels() );
    
    Mat cropped;
    getRectSubPix(rotated, size, box.center, cropped); //只支持CV_8U 或者CV_32F
//    copyMakeBorder(cropped, cropped, 3, 3, 3, 3, BORDER_CONSTANT,Scalar(0));
    return cropped;
}

@end

