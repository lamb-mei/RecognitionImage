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


+ (CVResult *) findCircles:(UIImage *)image
{
//    HoughCircles
    //先轉正照片
    image = [[self class] fixedOrientation:image];
    //取得 Mat
    cv::Mat imageMat_Orig;
    UIImageToMat(image, imageMat_Orig);
    
    CGSize osize;
    osize.width= imageMat_Orig.cols ;
    osize.height= imageMat_Orig.rows ;
    
    float scale_max = 1024;
    float rate = scale_max / imageMat_Orig.cols;
    
    
    cv::resize(imageMat_Orig, imageMat_Orig , cv::Size(scale_max , imageMat_Orig.rows * rate), 0, 0, CV_INTER_AREA);
    
    CGSize rsize;
    rsize.width= imageMat_Orig.cols ;
    rsize.height= imageMat_Orig.rows;
    
    CVResult *cvresult = [[CVResult alloc] initWithOrgi_size:osize size:rsize];
    
    //轉灰
    cv::Mat imageMat_Gray;
    cvtColor(imageMat_Orig, imageMat_Gray, cv::COLOR_BGR2GRAY);
    
    //模糊處理 抗噪
    cv::Mat imageMat_blur;
    //    blur(imageMat_Gray, imageMat_blur, cv::Size(5,5));
    blur(imageMat_Gray, imageMat_blur, cv::Size(5,5),cv::Point(-1,-1),0);
    
    Mat imageMat_canny , imageMat_canny2 , imageMat_canny3;
    Canny(imageMat_blur, imageMat_canny, 80, 50);
    Canny(imageMat_blur, imageMat_canny2, 60, 20);
    Canny(imageMat_blur, imageMat_canny3, 45, 15);
    
    
    vector<Vec3f> circles;
    //霍夫變換
    /*
        HoughCircles函式的原型為：
        void HoughCircles(InputArray image,OutputArray circles, int method, double dp, double minDist, double param1=100, double param2=100, int minRadius=0,int maxRadius=0 )
        image為輸入影象，要求是灰度影象
        circles為輸出圓向量，每個向量包括三個浮點型的元素——圓心橫座標，圓心縱座標和圓半徑
        method為使用霍夫變換圓檢測的演算法，Opencv2.4.9只實現了2-1霍夫變換，它的引數是CV_HOUGH_GRADIENT
        dp為第一階段所使用的霍夫空間的解析度，dp=1時表示霍夫空間與輸入影象空間的大小一致，dp=2時霍夫空間是輸入影象空間的一半，以此類推
        minDist為圓心之間的最小距離，如果檢測到的兩個圓心之間距離小於該值，則認為它們是同一個圓心
        param1、param2為閾值
        minRadius和maxRadius為所檢測到的圓半徑的最小值和最大值
    */
    double minDist = 50;
    double param1 = 90 , param2= 80;
    double minRadius = 0 ,maxRadius = 0;
    HoughCircles(imageMat_canny2, circles, CV_HOUGH_GRADIENT, 1, minDist, param1, param2, minRadius, maxRadius);
    
    cvtColor(imageMat_canny, imageMat_canny, cv::COLOR_GRAY2BGR);
    
    /// Draw the circles detected
    for( size_t i = 0; i < circles.size(); i++ )
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        // circle center
        circle( imageMat_canny, center, 3, Scalar(0,255,0), -1, 8, 0 );
        // circle outline
        circle( imageMat_canny, center, radius, Scalar(0,0,255), 3, 8, 0 );
     }
    
    
    
    NSMutableArray *arr =  [@[] mutableCopy];
    [arr addObject:MatToUIImage(imageMat_Orig)];
    [arr addObject:MatToUIImage(imageMat_Gray)];
    [arr addObject:MatToUIImage(imageMat_blur)];
    [arr addObject:MatToUIImage(imageMat_canny)];
    [arr addObject:MatToUIImage(imageMat_canny2)];
    [arr addObject:MatToUIImage(imageMat_canny3)];
    cvresult.preprocess = arr;
    
    return cvresult;
}


std::tuple<cv::Mat, cv::Mat> orb_test(cv::Mat& img1, cv::Mat& img2){
//  img1 = orgi
//  img2 = in scen
    int Hession = 400;
    double t1 = getTickCount();
    //特徵點提取
    cv::Ptr<ORB> detector = ORB::create(400);
    vector<KeyPoint> keypoints_obj;
    vector<KeyPoint> keypoints_scene;
    //定義描述子
    Mat descriptor_obj, descriptor_scene;
    //檢測並計算成描述子
    detector->detectAndCompute(img1, Mat(), keypoints_obj, descriptor_obj);
    detector->detectAndCompute(img2, Mat(), keypoints_scene, descriptor_scene);

    double t2 = getTickCount();
    double t = (t2 - t1) * 1000 / getTickFrequency();
    //特徵匹配
    FlannBasedMatcher fbmatcher(new flann::LshIndexParams(20, 10, 2));
    vector<DMatch> matches;
    //將找到的描述子進行匹配並存入matches中
    fbmatcher.match(descriptor_obj, descriptor_scene, matches);

    double minDist = 1000;
    double maxDist = 0;
    //找出最優描述子
    vector<DMatch> goodmatches;
    for (int i = 0; i < descriptor_obj.rows; i++)
    {
        double dist = matches[i].distance;
        if (dist < minDist)
        {
            minDist=dist ;
        }
        if (dist > maxDist)
        {
            maxDist=dist;
        }

    }
    for (int i = 0; i < descriptor_obj.rows; i++)
    {
        double dist = matches[i].distance;
        if (dist < max(2 * minDist, 0.02))
        {
            goodmatches.push_back(matches[i]);
        }
    }
    Mat orbImg;

    drawMatches(img1, keypoints_obj, img2, keypoints_scene, goodmatches, orbImg,
        Scalar::all(-1), Scalar::all(-1), vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);

    //----------目標物體用矩形標識出來------------
    vector<Point2f> obj;
    vector<Point2f>scene;
    for (size_t i = 0; i < goodmatches.size(); i++)
    {
        obj.push_back(keypoints_obj[goodmatches[i].queryIdx].pt);
        scene.push_back(keypoints_scene[goodmatches[i].trainIdx].pt);
    }
    vector<Point2f> obj_corner(4);
    vector<Point2f> scene_corner(4);
    //生成透視矩陣
    Mat H = findHomography(obj, scene, RANSAC);

    obj_corner[0] = cv::Point(0, 0);
    obj_corner[1] = cv::Point(img1.cols, 0);
    obj_corner[2] = cv::Point(img1.cols, img1.rows);
    obj_corner[3] = cv::Point(0, img1.rows);
    //透視變換
    perspectiveTransform(obj_corner, scene_corner, H);
    Mat resultImg=orbImg.clone();
    

    for (int i = 0; i < 4; i++)
    {
        line(resultImg, scene_corner[i]+ Point2f(img1.cols, 0), scene_corner[(i + 1) % 4]+ Point2f(img1.cols, 0), Scalar(0, 0, 255), 2, 8, 0);
    }

    cout << "ORB執行時間為:" << t << "ms" << endl;
    cout << "最小距離為：" <<minDist<< endl;
    cout << "最大距離為：" << maxDist << endl;

    //C++ 17
    return {resultImg,orbImg};
}

+ (CVResult *) findFeature:(UIImage *)image
{
//    HoughCircles
    //先轉正照片
    image = [[self class] fixedOrientation:image];
    //取得 Mat
    cv::Mat imageMat_Orig;
    UIImageToMat(image, imageMat_Orig);
    
    CGSize osize;
    osize.width= imageMat_Orig.cols ;
    osize.height= imageMat_Orig.rows ;
    
    float scale_max = 1024;
    float rate = scale_max / imageMat_Orig.cols;
    
    
    cv::resize(imageMat_Orig, imageMat_Orig , cv::Size(scale_max , imageMat_Orig.rows * rate), 0, 0, CV_INTER_AREA);
    
    CGSize rsize;
    rsize.width= imageMat_Orig.cols ;
    rsize.height= imageMat_Orig.rows;
    
    CVResult *cvresult = [[CVResult alloc] initWithOrgi_size:osize size:rsize];
    
    
    UIImage *lamb = [UIImage imageNamed:@"lamb.png"];
    cv::Mat mat_lamb;
    UIImageToMat(lamb, mat_lamb);
    auto [mat1, mat2] = orb_test(mat_lamb,imageMat_Orig);
    
    NSMutableArray *arr =  [@[] mutableCopy];
    [arr addObject:MatToUIImage(imageMat_Orig)];
    [arr addObject:MatToUIImage(mat1)];
    [arr addObject:MatToUIImage(mat2)];

    cvresult.preprocess = arr;
    
    return cvresult;
}




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

