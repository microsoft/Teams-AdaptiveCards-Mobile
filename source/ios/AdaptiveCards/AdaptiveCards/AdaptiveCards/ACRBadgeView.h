//
//  ACRBadgeView.h
//  AdaptiveCards
//
//  Created by reenulnu on 09/10/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ACRView.h"
#import "ACOEnums.h"

@interface ACRBadgeView : UIView

- (instancetype)initWithText:(NSString*)text
                        image:(UIView*)imageView
                    appearance:(ACRBadgeAppearance)appearance
                    iconPosition:(ACRIconPosition)iconPosition
                            size:(ACRBadgeSize)size
                           shape:(ACRShape)shape
                            style:(ACRBadgeStyle)style
                        hostConfig:(ACOHostConfig *)hostConfig;

@end
