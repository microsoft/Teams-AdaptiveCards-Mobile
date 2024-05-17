//
//  ACRRatingInputView.m
//  AdaptiveCards
//
//  Created by Abhishek on 17/05/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRRatingInputView.h"
#import "ACOBundle.h"
#import <Foundation/Foundation.h>
#import "ACOHostConfigPrivate.h"

@implementation ACRRatingInputView
{
    ACRRatingSize _ratingSize;
    ACRRatingColor _ratingColor;
    NSMutableArray<UIImageView *> *_starImageViews;
    NSInteger _max;
    NSInteger _value;
    BOOL _readOnly;
}

- (instancetype)init:(NSInteger)value
                 max:(NSInteger)max
                size:(ACRRatingSize)size
         ratingColor:(ACRRatingColor)ratingColor
            readOnly:(BOOL)readOnly
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _max = max;
        _value = value;
        _ratingColor = ratingColor;
        _ratingSize = size;
        _readOnly = readOnly;
        [self setupView];
    }
    return self;
}

- (void)setupView 
{
    _starImageViews = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _max; i++) 
    {
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[self emptyStarImage]];
        starImageView.tintColor = [self colorForStars];
        starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:starImageView];
        [_starImageViews addObject:starImageView];
        
        if(!_readOnly)
        {
            starImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStarTap:)];
            [starImageView addGestureRecognizer:tapGesture];
        }
    }
    
    [self setupConstraints];
    [self updateStarImages];
}

- (void)setupConstraints 
{
    for (NSInteger i = 0; i < _starImageViews.count; i++) 
    {
        UIImageView *starImageView = _starImageViews[i];
        
        // top and bottom
        [NSLayoutConstraint activateConstraints:@[
            [starImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [starImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];

        if (i == 0)
        {
            // Leading constraint for the first star
            [NSLayoutConstraint activateConstraints:@[
                [starImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            ]];
        }
        else
        {
            // Horizontal spacing between stars
            UIImageView *previousStarImageView = _starImageViews[i - 1];
            [NSLayoutConstraint activateConstraints:@[
                [starImageView.leadingAnchor constraintEqualToAnchor:previousStarImageView.trailingAnchor constant:12]
            ]];
        }
        
        // Width and height constraints for each star
        [NSLayoutConstraint activateConstraints:@[
            [starImageView.widthAnchor constraintEqualToConstant:[self sizeOfStar].width],
            [starImageView.heightAnchor constraintEqualToConstant:[self sizeOfStar].height]
        ]];
        
        if (i == _starImageViews.count - 1) {
            // Trailing constraint for the last star
            [NSLayoutConstraint activateConstraints:@[
                [starImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
            ]];
        }
    }
}

- (UIImage *)emptyStarImage 
{
    NSString *nameOfStar = (_ratingSize == ACRMedium) ? @"ic_fluent_star_28_regular" : @"ic_fluent_star_32_regular";
    UIImage *emptyStarImage = [UIImage imageNamed:nameOfStar inBundle:[[ACOBundle getInstance] getBundle] compatibleWithTraitCollection:nil];
    return emptyStarImage;
}

- (UIImage *)filledStarImage 
{
    NSString *nameOfStar = (_ratingSize == ACRMedium) ? @"ic_fluent_star_28_filled" : @"ic_fluent_star_32_filled";
    UIImage *filledStarImage = [UIImage imageNamed:nameOfStar inBundle:[[ACOBundle getInstance] getBundle] compatibleWithTraitCollection:nil];
    return filledStarImage;
}

- (void)handleStarTap:(UITapGestureRecognizer *)gesture 
{
    UIImageView *tappedStar = (UIImageView *)gesture.view;
    NSInteger index = [_starImageViews indexOfObject:tappedStar];
    _value = index + 1;
    [self updateStarImages];
}

- (void)updateStarImages 
{
    for (NSInteger i = 0; i < _starImageViews.count; i++) {
        UIImageView *starImageView = _starImageViews[i];
        if (i < _value) {
            starImageView.image = [self filledStarImage];
        } else {
            starImageView.image = [self emptyStarImage];
        }
    }
}

- (UIColor *)colorForStars
{
    switch (_ratingColor) {
        case ACRMarigold:
            return [ACOHostConfig convertHexColorCodeToUIColor: "#EAA300"];
            
        case ACRNeutral:
            return [ACOHostConfig convertHexColorCodeToUIColor: "#242424"];
            
        default:
            return [ACOHostConfig convertHexColorCodeToUIColor: "#242424"];
    }
}

- (CGSize)sizeOfStar
{
    switch (_ratingSize) {
        case ACRMedium:
            return CGSizeMake(28, 28);
            
        case ACRLarge:
            return CGSizeMake(32, 32);
            
        default:
            return CGSizeMake(28, 28);
    }
}

@end

