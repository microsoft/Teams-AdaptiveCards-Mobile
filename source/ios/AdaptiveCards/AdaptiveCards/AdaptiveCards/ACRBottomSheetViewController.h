//
//  ACRPopoverSheetVC.h
//  AdaptiveCards
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACRBottomSheetConfiguration.h"


@interface ACRBottomSheetViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, copy) void (^onDismissBlock)(void);

- (instancetype)initWithContent:(UIView *)content
                      configuration:(ACRBottomSheetConfiguration *)configuration;
@end

