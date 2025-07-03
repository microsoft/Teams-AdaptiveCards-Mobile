//
//  ACRBaseTarget
//  ACRBaseTarget.h
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACOBaseActionElement.h"
#import "ACRTapGestureRecognizerEventHandler.h"
#import <UIKit/UIKit.h>

@class ACRPopoverTarget;

@interface ACRBaseTarget : NSObject <ACRSelectActionDelegate>

@property (nonatomic, weak) ACRPopoverTarget *parentPopoverTarget;

- (void)addGestureRecognizer:(UIView *)view toolTipText:(NSString *)toolTipText;

- (void)setTooltip:(UIView *)view toolTipText:(NSString *)toolTipText;

- (void)showToolTip:(UILongPressGestureRecognizer *)gesture;

@end
