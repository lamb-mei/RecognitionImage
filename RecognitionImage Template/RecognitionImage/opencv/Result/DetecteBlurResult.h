//
//  DetecteBlurResult.h
//  RecognitionInvoice
//
//  Created by 羊小咩 on 2020/7/29.
//  Copyright © 2020 咩橘客. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetecteBlurResult : NSObject

@property(assign, readonly) double variance;
@property(nonatomic, readonly) BOOL isBlur;

- (instancetype)initWithAttributes:(BOOL)isBlur variance:(double)variance;
@end

NS_ASSUME_NONNULL_END
