//
//  ACRCarouselViewBottomBar.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "CarouselViewBottomBar.h"
#import "ACRPageIndicator.h"

@interface CarouselViewBottomBar ()

@property  UILabel * label;

@property UIButton* chevronLeftButton;
@property NSInteger currentViewindex;
@property NSArray<UIView *> *views;
@property PageControl *pageControl;

@end

@implementation CarouselViewBottomBar

-(instancetype) initWithViews:(NSArray<UIView *>*)carouselPageView {
    self = [super initWithFrame:CGRectZero];
    self.views = carouselPageView;
    for(UIView *view in self.views) {
        view.hidden = YES;
    }
    self.currentViewindex = 0;
    self.views[0].hidden = NO;
    PageControlConfig *pageControlConfig = [[PageControlConfig alloc] initWithNumberOfPages:self.views.count
                                                                               displayPages:@5
                                                                         hidesForSinglePage:@0
                                                                   accessibilityValueFormat:@""];
    
    self.pageControl = [[PageControl alloc] initWithFrame:CGRectZero];
    [self.pageControl setConfig:pageControlConfig];
    [self addSubview:self.pageControl];
    
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

- (void) layoutSubviews {

    [super layoutSubviews];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.centerXAnchor constraintEqualToAnchor:self.pageControl.centerXAnchor],
        [self.topAnchor constraintEqualToAnchor:self.pageControl.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:self.pageControl.bottomAnchor]
    ]];
}

-(void) showPreviousView {
    NSInteger newCurrentViewindex = ((self.currentViewindex -1) + self.views.count) % self.views.count;
    [self.pageControl setCurrentPage:newCurrentViewindex];
    [self slideAnimationForPreviousView:self.views[self.currentViewindex] showView:self.views[newCurrentViewindex]];
    self.currentViewindex = newCurrentViewindex;
}

-(void) showNextView {
    NSInteger newCurrentViewindex = (self.currentViewindex +1 ) % self.views.count;
    [self.pageControl setCurrentPage:newCurrentViewindex];
    [self slideAnimationForNextView:self.views[self.currentViewindex] showView:self.views[newCurrentViewindex]];
    self.currentViewindex = newCurrentViewindex;
}

-(void) setViewWithCurrentIndex {
    for (NSInteger i=0; i<_views.count;i++) {
        self.views[i].hidden = YES;
    }
    self.views[self.currentViewindex].hidden = NO;
}

- (void)slideAnimationForNextView:(UIView *)viewToHide showView:(UIView *)viewToShow {
    // Prepare the view to show
    viewToShow.transform = CGAffineTransformMakeTranslation(viewToShow.bounds.size.width, 0);
    viewToShow.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        // Slide out the current view
        viewToHide.transform = CGAffineTransformMakeTranslation(-viewToHide.bounds.size.width, 0);
        
        // Slide in the new view
        viewToShow.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.transform = CGAffineTransformIdentity; // Reset transform for future use
    }];
}

- (void)slideAnimationForPreviousView:(UIView *)viewToHide showView:(UIView *)viewToShow {
    // Prepare the view to show
    viewToShow.transform = CGAffineTransformMakeTranslation(-viewToShow.bounds.size.width, 0);
    viewToShow.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        // Slide out the current view
        viewToHide.transform = CGAffineTransformMakeTranslation(viewToHide.bounds.size.width, 0);

        // Slide in the new view
        viewToShow.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.transform = CGAffineTransformIdentity; // Reset transform for future use
    }];
}

- (void)crossfadeAnimationForView:(UIView *)viewToHide showView:(UIView *)viewToShow {
    // Prepare the view to show
    viewToShow.alpha = 0.0;
    viewToShow.hidden = NO;

    [UIView animateWithDuration:0.3 animations:^{
        // Fade out the current view
        viewToHide.alpha = 0.0;

        // Fade in the new view
        viewToShow.alpha = 1.0;
    } completion:^(BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.alpha = 1.0; // Reset alpha for future use
    }];
}
@end

