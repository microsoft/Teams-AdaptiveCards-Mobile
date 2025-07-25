//
//  ACRUIImageView.h
//  AdaptiveCards
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACOBaseCardElement.h"
#import "ACREnums.h"
#import <UIKit/UIKit.h>

typedef void (^ACRImageSetCompletionBlock)(UIImageView *imageView);

@interface ACRUIImageView : UIImageView
@property BOOL isPersonStyle;
@property CGSize desiredSize;
@property ACRImageSize adaptiveImageSize;
@property (nonatomic, copy) ACRImageSetCompletionBlock imageSetCompletionBlock;
@end
