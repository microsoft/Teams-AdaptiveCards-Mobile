//
//  ACRCarouselViewBottomBar.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "CarouselViewBottomBar.h"

@interface CarouselViewBottomBar ()

@property  UILabel * label;

@property UIButton* chevronLeftButton;
@property NSInteger currentViewindex;
@property NSArray<CarouselPageView *> *views;

@end

@implementation CarouselViewBottomBar

-(instancetype) initWithViews:(NSArray<CarouselPageView *>*)carouselPageView {
    self = [super initWithFrame:CGRectZero];
    self.views = carouselPageView;
    for(CarouselPageView *view in self.views) {
        view.hidden = YES;
    }
    self.currentViewindex = 0;
    self.views[0].hidden = NO;
    return self;
}

- (void) layoutSubviews {

    [super layoutSubviews];
    
    [self configureChevronLeftButton];
    [self configureChevronRightButton];
}

-(void) configureChevronRightButton {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];

    // Set the chevron image using SF Symbols (iOS 13+)
    UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.right" ];
    [rightButton setImage:chevronImage forState:UIControlStateNormal];
    
    UIView *containerView = [[UIStackView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:containerView];
    
    // set a tint color for the chevron
    rightButton.tintColor = [UIColor colorWithRed:66/255 green:66/255 blue:66/255 alpha:1.0];
    

    // Add the button to your view
    [self addSubview:rightButton];
    
    rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [rightButton.trailingAnchor constraintEqualToAnchor:self.centerXAnchor constant:16],
        [rightButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [rightButton.widthAnchor constraintEqualToConstant:6.5],
        [rightButton.heightAnchor constraintEqualToConstant:12]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [containerView.trailingAnchor constraintEqualToAnchor:rightButton.trailingAnchor constant:5],
        [containerView.bottomAnchor constraintEqualToAnchor:rightButton.bottomAnchor constant:5],
        [containerView.topAnchor constraintEqualToAnchor:rightButton.topAnchor constant:-5],
        [containerView.leadingAnchor constraintEqualToAnchor:rightButton.leadingAnchor constant:-5]
        
    ]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(chevronRightButtonTapped:)];
    [containerView addGestureRecognizer:tapGesture];
}

-(void) configureChevronLeftButton {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];

    // Set the chevron image using SF Symbols (iOS 13+)
    UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.left"];
    [leftButton setImage:chevronImage forState:UIControlStateNormal];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:containerView];
    
    // set a tint color for the chevron
    leftButton.tintColor = [UIColor colorWithRed:66/255 green:66/255 blue:66/255 alpha:1.0];
    

    // Add the button to your view
    [self addSubview:leftButton];
    
    leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [leftButton.trailingAnchor constraintEqualToAnchor:self.centerXAnchor constant:-16],
        [leftButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [leftButton.widthAnchor constraintEqualToConstant:6.5],
        [leftButton.heightAnchor constraintEqualToConstant:12]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [containerView.trailingAnchor constraintEqualToAnchor:leftButton.trailingAnchor constant:5],
        [containerView.bottomAnchor constraintEqualToAnchor:leftButton.bottomAnchor constant:5],
        [containerView.topAnchor constraintEqualToAnchor:leftButton.topAnchor constant:-5],
        [containerView.leadingAnchor constraintEqualToAnchor:leftButton.leadingAnchor constant:-5]
    ]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(chevronLeftButtonTapped:)];
    [containerView addGestureRecognizer:tapGesture];
}

- (void)chevronLeftButtonTapped:(UIButton *)sender {
    [self showPreviousView];
}

- (void) chevronRightButtonTapped:(UITapGestureRecognizer *)sender {
    [self showNextView];
}

-(void) showPreviousView {
    NSInteger newCurrentViewindex = ((self.currentViewindex -1) + self.views.count) % self.views.count;
    [self slideAnimationForPreviousView:self.views[self.currentViewindex] showView:self.views[newCurrentViewindex]];
    self.currentViewindex = newCurrentViewindex;
}

-(void) showNextView {
    NSInteger newCurrentViewindex = (self.currentViewindex +1 ) % self.views.count;
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

