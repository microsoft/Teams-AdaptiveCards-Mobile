//
//  ACRRatingInputView.m
//  AdaptiveCards
//
//  Created by Abhishek on 17/05/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRRatingView.h"
#import "ACOBundle.h"
#import <Foundation/Foundation.h>
#import "ACOHostConfigPrivate.h"

@implementation ACRRatingView
{
    ACRRatingSize _ratingSize;
    ACRRatingColor _ratingColor;
    ACRRatingStyle _style;
    ACOHostConfig *_hostConfig;
    NSMutableArray<UIImageView *> *_starImageViews;
    UILabel *_ratingLabel;
    NSInteger _max;
    double _value;
    BOOL _readOnly;
    NSInteger _count;
    
}

- (instancetype)initWithEditableValue:(double)value
                                  max:(NSInteger)max
                                 size:(ACRRatingSize)size
                          ratingColor:(ACRRatingColor)ratingColor
                           hostConfig:(ACOHostConfig *)hostConfig

{
    self = [super initWithFrame:CGRectZero];
    if (self) 
    {
        _max = max;
        _value = value;
        _ratingColor = ratingColor;
        _ratingSize = size;
        _readOnly = NO;
        _count = 0;
        _style = ACRDefaultStyle;
        _hostConfig = hostConfig;
        [self setupViewForInput];
    }
    return self;
}

- (instancetype)initWithReadonlyValue:(double)value
                                  max:(NSInteger)max
                                 size:(ACRRatingSize)size
                          ratingColor:(ACRRatingColor)ratingColor
                                style:(ACRRatingStyle)style
                                count:(NSInteger)count
                           hostConfig:(ACOHostConfig *)hostConfig
{
    self = [super initWithFrame:CGRectZero];
    if (self) 
    {
        _max = max;
        _value = value;
        _ratingColor = ratingColor;
        _ratingSize = size;
        _readOnly = YES;
        _count = count;
        _style = style;
        hostConfig = hostConfig;
        [self setupReadOnlyView];
    }
    return self;
}

- (void)setupViewForInput
{
    _starImageViews = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _max; i++)
    {
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[self emptyStarImage]];
        starImageView.tintColor = [self colorForStars];
        starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:starImageView];
        [_starImageViews addObject:starImageView];
        starImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStarTap:)];
        [starImageView addGestureRecognizer:tapGesture];
    }
    
    [self setupConstraints];
    [self updateStarImages];
}

- (void)setupReadOnlyView
{
    _starImageViews = [NSMutableArray array];
    if(_style == ACRCompactStyle)
    {
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[self emptyStarImage]];
        starImageView.tintColor = [self colorForStars];
        starImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:starImageView];
        [_starImageViews addObject:starImageView];
    }
    else
    {
        for (NSInteger i = 0; i < _max; i++)
        {
            UIImageView *starImageView = [[UIImageView alloc] initWithImage:[self emptyStarImage]];
            starImageView.tintColor = [self colorForStars];
            starImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:starImageView];
            [_starImageViews addObject:starImageView];
        }
    }
    
    _ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _ratingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ratingLabel.attributedText = [self atrributedStringForLabel];
    [self addSubview:_ratingLabel];
    
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
            if(_ratingLabel != nil)
            {
                [NSLayoutConstraint activateConstraints:@[
                    [_ratingLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
                ]];
                [NSLayoutConstraint activateConstraints:@[
                    [_ratingLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
                ]];
                [NSLayoutConstraint activateConstraints:@[
                    [starImageView.trailingAnchor constraintEqualToAnchor:_ratingLabel.leadingAnchor constant:-12]
                ]];
            }
            else
            {
                [NSLayoutConstraint activateConstraints:@[
                    [starImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
                ]];
            }
        }
    }
}

- (NSInteger)getValue
{
    return _value;
}

- (UIImage *)emptyStarImage 
{
    NSString *nameOfStar = [[NSString alloc] initWithFormat:@"ic_fluent_star_%ld_regular", (long)([self sizeOfStar].width)];
    UIImage *emptyStarImage = [UIImage imageNamed:nameOfStar inBundle:[[ACOBundle getInstance] getBundle] compatibleWithTraitCollection:nil];
    return emptyStarImage;
}

- (UIImage *)filledStarImage 
{
    NSString *nameOfStar = [[NSString alloc] initWithFormat:@"ic_fluent_star_%ld_filled", (long)([self sizeOfStar].width)];
    UIImage *filledStarImage = [UIImage imageNamed:nameOfStar inBundle:[[ACOBundle getInstance] getBundle] compatibleWithTraitCollection:nil];
    return filledStarImage;
}

- (void)handleStarTap:(UITapGestureRecognizer *)gesture 
{
    UIImageView *tappedStar = (UIImageView *)gesture.view;
    NSInteger index = [_starImageViews indexOfObject:tappedStar];
    _value = index + 1;
    [self updateStarImages];
    [_ratingValueChangeDelegate didChangeValueTo:_value];
}

- (void)updateStarImages 
{
    NSInteger totalFilledStars = (NSInteger)_value;
    for (NSInteger i = 0; i < _starImageViews.count; i++) {
        UIImageView *starImageView = _starImageViews[i];
        if (i < totalFilledStars) {
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
            return _readOnly ? CGSizeMake(24, 24) : CGSizeMake(28, 28);
            
        case ACRLarge:
            return _readOnly ? CGSizeMake(28, 28): CGSizeMake(32, 32);
            
        default:
            return CGSizeMake(28, 28);
    }
}

- (NSAttributedString *)atrributedStringForLabel
{
    NSString *ratingValue = [[NSString alloc] initWithFormat:@"%.1f", _value];
    NSMutableAttributedString *ratingAttributedStr = [[NSMutableAttributedString alloc] initWithString:ratingValue];
    [ratingAttributedStr addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:NSUnderlineStyleDouble]
                            range:NSMakeRange(0, ratingAttributedStr.length)];

     [ratingAttributedStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor blueColor]
                            range:NSMakeRange(0, ratingAttributedStr.length)];
    
    if(_count != 0)
    {
        NSMutableAttributedString *ratingCountStr = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"• %ld", (long)_count]];
        
        [ratingCountStr addAttribute:NSUnderlineStyleAttributeName
                                value:[NSNumber numberWithInt:NSUnderlineStyleDouble]
                                range:NSMakeRange(0, ratingCountStr.length)];

         [ratingCountStr addAttribute:NSForegroundColorAttributeName
                                value:[UIColor redColor]
                                range:NSMakeRange(0, ratingCountStr.length)];
        
        [ratingAttributedStr appendAttributedString:ratingCountStr];
    }
    
    return ratingAttributedStr;
}

@end

