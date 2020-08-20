//
//  DetecteBlurResult.m
//  RecognitionInvoice
//
//  Created by 羊小咩 on 2020/7/29.
//  Copyright © 2020 咩橘客. All rights reserved.
//

#import "DetecteBlurResult.h"


@implementation DetecteBlurResult

- (instancetype)initWithAttributes:(BOOL)isBlur variance:(double)variance{
    self = [super init];
    
    if (self) {
        _isBlur = isBlur;
        _variance = (double) variance;
    }
    return self;
}

@end
