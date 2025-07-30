//
//  ACRBottomSheetPresentationController.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRBottomSheetPresentationController.h"

@interface ACRBottomSheetPresentationController ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation ACRBottomSheetPresentationController

- (CGRect) frameOfPresentedViewInContainerView
{
    CGFloat targetHeight = self.presentedViewController.preferredContentSize.height;
    return CGRectMake(0, self.containerView.bounds.size.height - targetHeight, self.containerView.bounds.size.width, targetHeight);
}

- (void) containerViewWillLayoutSubviews
{
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    self.presentedView.layer.cornerRadius = 10;
    self.presentedView.clipsToBounds = YES;
}

- (void) presentationTransitionWillBegin
{
    if (!self.dimmingView)
    {
        self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    }
    self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.dimmingView.alpha = 0.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTap:)];
    [self.dimmingView addGestureRecognizer:tapGesture];
    
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.dimmingView.alpha = 1.0;
    }];
}

- (void) dismissalTransitionWillBegin
{
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.dimmingView.alpha = 0.0;
    }];
}

- (void) dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed)
    {
        [self.dimmingView removeFromSuperview];
        self.dimmingView = nil;
    }
}

- (void) handleDimmingViewTap:(UITapGestureRecognizer *)gesture
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
