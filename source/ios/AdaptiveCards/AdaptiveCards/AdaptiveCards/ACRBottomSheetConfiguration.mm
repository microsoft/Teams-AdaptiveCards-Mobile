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
{
    if (self = [super init]) {
        _minHeightMultiplier = minMultiplier;
        _maxHeightMultiplier = maxMultiplier;
        
        _borderHeight           = 0.5;
        _closeButtonTopInset    = 16;
        _closeButtonSideInset   = 12;
        _closeButtonToScrollGap = 20;
        _contentPadding         = 16;
        _closeButtonSize        = 28.0;
        
    }
    return self;
}
@end
