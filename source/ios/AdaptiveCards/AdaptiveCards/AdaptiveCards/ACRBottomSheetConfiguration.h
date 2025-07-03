//
//  ACRBottomSheetConfiguration.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACRBottomSheetConfiguration : NSObject
@property CGFloat minHeightMultiplier;
@property CGFloat maxHeightMultiplier;

@property CGFloat borderHeight;
@property CGFloat closeButtonTopInset;
@property CGFloat closeButtonSideInset;
@property CGFloat closeButtonToScrollGap;
@property CGFloat contentPadding;
@property CGFloat closeButtonSize;

- (instancetype)initWithMinMultiplier:(CGFloat)minMultiplier
                       maxMultiplier:(CGFloat)maxMultiplier;

@end
