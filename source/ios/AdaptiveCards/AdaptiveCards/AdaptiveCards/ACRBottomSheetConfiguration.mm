//
//  ACRBottomSheetConfiguration.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRBottomSheetConfiguration.h"

@implementation ACRBottomSheetConfiguration

- (instancetype)initWithMinMultiplier:(CGFloat)minMultiplier
                        maxMultiplier:(CGFloat)maxMultiplier
                         borderHeight:(CGFloat)borderHeight
                  closeButtonTopInset:(CGFloat)closeButtonTopInset
                 closeButtonSideInset:(CGFloat)closeButtonSideInset
               closeButtonToScrollGap:(CGFloat)closeButtonToScrollGap
                       contentPadding:(CGFloat)contentPadding
                      closeButtonSize:(CGFloat)closeButtonSize
                        acoHostConfig:(ACOHostConfig *)hostConfig
{
    self = [super init];
    if (self)
    {
        self.minHeightMultiplier = minMultiplier;
        self.maxHeightMultiplier = maxMultiplier;
        self.borderHeight = borderHeight;
        self.closeButtonTopInset = closeButtonTopInset;
        self.closeButtonSideInset = closeButtonSideInset;
        self.closeButtonToScrollGap = closeButtonToScrollGap;
        self.contentPadding = contentPadding;
        self.closeButtonSize = closeButtonSize;
        self.hostConfig = hostConfig;
    }
    return self;
}

+ (instancetype)defaultWithHostConfig:(ACOHostConfig *)hostConfig {
    return [[ACRBottomSheetConfiguration alloc] initWithMinMultiplier:0.2
                                                        maxMultiplier:0.66
                                                         borderHeight:0.5
                                                  closeButtonTopInset:16
                                                 closeButtonSideInset:12
                                               closeButtonToScrollGap:20
                                                       contentPadding:16
                                                      closeButtonSize:28.0
                                                        acoHostConfig:hostConfig];
}

@end
