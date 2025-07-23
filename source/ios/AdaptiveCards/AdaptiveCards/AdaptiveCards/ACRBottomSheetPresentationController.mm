//
//  ACRBottomSheetPresentationController.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRBottomSheetPresentationController.h"

@implementation ACRBottomSheetPresentationController{
    UIView *dimmingView;
}
- (CGRect)frameOfPresentedViewInContainerView
{

    CGFloat want = self.presentedViewController.preferredContentSize.height;
    return CGRectMake(0, self.containerView.bounds.size.height - want, self.containerView.bounds.size.width, want);
}

- (void)containerViewWillLayoutSubviews
{
    dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    self.presentedView.layer.cornerRadius = 10;
    self.presentedView.clipsToBounds = YES;
}

- (void)presentationTransitionWillBegin {
    dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    dimmingView.alpha = 0.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTap:)];
        [dimmingView addGestureRecognizer:tapGesture];

    [self.containerView insertSubview:dimmingView atIndex:0];
    [UIView animateWithDuration:0.25 animations:^{
        self->dimmingView.alpha = 1.0;
        }];
}

- (void)dismissalTransitionWillBegin {
  
    [UIView animateWithDuration:0.25 animations:^{
        self->dimmingView.alpha = 0.0;
        }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [dimmingView removeFromSuperview];
        dimmingView = nil;
    }
}

- (void)handleDimmingViewTap:(UITapGestureRecognizer *)gesture {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
