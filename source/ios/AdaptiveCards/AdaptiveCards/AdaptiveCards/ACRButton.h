//
//  ACRButton
//  ACRButton.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRView.h"
#import <UIKit/UIKit.h>

@interface ACRButton : UIButton

@property BOOL positiveUseDefault;
@property UIColor *positiveForegroundColor;
@property UIColor *positiveBackgroundColor;
@property BOOL destructiveUseDefault;
@property UIColor *destructiveForegroundColor;
@property UIColor *destructiveBackgroundColor;
@property NSString *sentiment;
@property UIColor *defaultPositiveBackgroundColor;
@property UIColor *defaultDestructiveForegroundColor;
@property ACRIconPlacement iconPlacement;
@property ACRActionType actionType;

+ (UIButton *)rootView:(ACRView *)rootView
     baseActionElement:(ACOBaseActionElement *)acoAction
                 title:(NSString *)title
         andHostConfig:(ACOHostConfig *)config;

- (instancetype)initWithExpandable:(BOOL)expandable;

- (void)setImageView:(UIImage *)image withConfig:(ACOHostConfig *)config;
- (void)setImageView:(UIImage *)image withConfig:(ACOHostConfig *)config widthToHeightRatio:(float)widthToHeightRatio;

- (void)applySentimentStyling;
@end
