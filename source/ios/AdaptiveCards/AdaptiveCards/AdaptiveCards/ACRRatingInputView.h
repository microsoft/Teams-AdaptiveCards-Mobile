//
//  ACRInputToggleView.h
//  AdaptiveCards
//
//  Copyright © 2020 Microsoft. All rights reserved.
//


#import "ACOBaseCardElement.h"
#import "ACRIBaseInputHandler.h"
#import <UIKit/UIKit.h>
#import "ACRView.h"

@interface ACRRatingInputView : UIView

- (instancetype)init:(NSInteger)value
                 max:(NSInteger)max
                size:(ACRRatingSize)size
         ratingColor:(ACRRatingColor)ratingColor
            readOnly:(BOOL)readOnly;


@end

