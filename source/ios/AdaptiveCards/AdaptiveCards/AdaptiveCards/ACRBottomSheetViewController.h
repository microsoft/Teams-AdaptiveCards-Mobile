//
//  ACRBottomSheetViewController.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACRBottomSheetConfiguration.h"

@interface ACRBottomSheetViewController: UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, copy) void (^onDismissBlock)(void);

- (instancetype)initWithContent:(UIView *)content configuration:(ACRBottomSheetConfiguration *)configuration;

@end

