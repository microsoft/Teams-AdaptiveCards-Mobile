//
//  ACRBottomSheetConfiguration.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACOHostConfig.h"

@interface ACRBottomSheetConfiguration : NSObject

@property CGFloat minHeightMultiplier;
@property CGFloat maxHeightMultiplier;
@property CGFloat borderHeight;
@property CGFloat closeButtonTopInset;
@property CGFloat closeButtonSideInset;
@property CGFloat closeButtonToScrollGap;
@property CGFloat contentPadding;
@property CGFloat closeButtonSize;
@property BOOL showCloseButton;
@property ACOHostConfig *hostConfig;

- (instancetype)initWithMinMultiplier:(CGFloat)minMultiplier
                        maxMultiplier:(CGFloat)maxMultiplier
                         borderHeight:(CGFloat)borderHeight
                  closeButtonTopInset:(CGFloat)closeButtonTopInset
                 closeButtonSideInset:(CGFloat)closeButtonSideInset
               closeButtonToScrollGap:(CGFloat)closeButtonToScrollGap
                       contentPadding:(CGFloat)contentPadding
                      closeButtonSize:(CGFloat)closeButtonSize
                       showCloseButton:(BOOL)showCloseButton
                        acoHostConfig:(ACOHostConfig *)hostConfig;

+ (instancetype)defaultWithHostConfig:(ACOHostConfig *)hostConfig;

@end
