//
//  ACRSVGImageView.h
//  AdaptiveCards
//
//  Created by Abhishek on 26/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOBaseCardElement.h"
#import "ACOHostConfig.h"
#import "ACOEnums.h"
#import <UIKit/UIKit.h>

@interface ACRSVGImageView : UIImageView

@property UIColor *svgTintColor;
@property UIImage *svgImage;
@property CGSize size;

- (instancetype)init:(NSString *)iconURL
                 rtl:(ACRRtl)rtl
                size:(CGSize)size
           tintColor:(UIColor *)tintColor;
@end
