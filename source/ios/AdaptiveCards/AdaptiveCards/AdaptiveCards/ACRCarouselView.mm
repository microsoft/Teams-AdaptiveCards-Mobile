//
//  CarouselView.m
//  Carousel element
//
//  Created by Abhishek Gupta on 22/08/24.
//

#import "ACRCarouselView.h"
#include "CarouselViewBottomBar.h"
#import "CarouselPageView.h"

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
    
    for(UIView *view in self.carouselViewBottomBar.views) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [view.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.heightAnchor constraintGreaterThanOrEqualToAnchor:view.heightAnchor]
        ]];
    }
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
