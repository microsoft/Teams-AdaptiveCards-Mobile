//
//  CarouselView.m
//  Carousel element
//
//  Created by Abhishek Gupta on 22/08/24.
//

#import "ACRCarouselView.h"
#include "CarouselViewBottomBar.h"
#import "CarouselPageView.h"
#import "ACRPageIndicator.h"

@interface CarouselView ()

@property CarouselViewBottomBar *carouselViewBottomBar;
@property (nonatomic, strong) UICollectionView *carouselCollectionView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CarouselView

-(instancetype) initWithCarouselViewBottomBar:(CarouselViewBottomBar*) carouselViewBottomBar {
    self = [super initWithFrame:CGRectZero];
    self.carouselViewBottomBar = carouselViewBottomBar;
    return self;
}

-(void)layoutSubviews {
    
    UIView * pageView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:pageView];
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    for(UIView *view in self.carouselViewBottomBar.views) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [pageView addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [pageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [pageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [pageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [view.leadingAnchor constraintEqualToAnchor:pageView.leadingAnchor],
            [view.trailingAnchor constraintEqualToAnchor:pageView.trailingAnchor],
            [view.topAnchor constraintEqualToAnchor:pageView.topAnchor],
            [pageView.heightAnchor constraintGreaterThanOrEqualToAnchor:view.heightAnchor]
        ]];
    }
    self.carouselViewBottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.carouselViewBottomBar];
    [NSLayoutConstraint activateConstraints:@[
        [self.carouselViewBottomBar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.carouselViewBottomBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.carouselViewBottomBar.topAnchor constraintEqualToAnchor:pageView.bottomAnchor constant:20],
        [self.bottomAnchor constraintEqualToAnchor:self.carouselViewBottomBar.bottomAnchor]
    ]];
    
    [self constructSwipeActions];
}

-(void) constructSwipeActions {
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleRightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipe];
}

- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)gesture {
    [self.carouselViewBottomBar showNextView];
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)gesture {
    [self.carouselViewBottomBar showPreviousView];
}

@end
