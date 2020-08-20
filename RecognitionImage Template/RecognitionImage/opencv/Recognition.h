//
//  Recognition.h
//  RecognitionInvoice
//
//  Created by 羊小咩 on 2020/7/9.
//  Copyright © 2020 咩橘客. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DetecteBlurResult.h"
#import "Constants.h"



NS_ASSUME_NONNULL_BEGIN

@class InvoiceResult;

@interface Recognition : NSObject


+(UIImage *) fixedOrientation:(UIImage *) image ;

+ (DetecteBlurResult *) detecteBlur:(UIImage *) image;
+ (DetecteBlurResult *) detecteBlur:(UIImage *) image threshold:(double)threshold;




@end

NS_ASSUME_NONNULL_END


