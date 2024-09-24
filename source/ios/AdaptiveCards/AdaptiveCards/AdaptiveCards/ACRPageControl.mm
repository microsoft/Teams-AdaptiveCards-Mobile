//
//  ACRPageIndicator.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 12/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRPageControl.h"

@interface ACRPageControlConfig()

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign, nonnull) NSNumber *displayPages;
@property (nonatomic, assign, nonnull) NSNumber *hidesForSinglePage;
@property (nonatomic, strong, nonnull) UIColor *selctedTintColor;
@property (nonatomic, strong, nonnull) UIColor *unselctedTintColor;

@end

@implementation ACRPageControlConfig

- (instancetype _Nonnull)initWithNumberOfPages:(NSInteger)numberOfPages displayPages:(nullable NSNumber *)displayPages
                              selctedTintColor:(UIColor * _Nonnull)selctedTintColor
                            unselctedTintColor:(UIColor * _Nonnull)unselctedTintColor 
{
    self = [super init];
    if(self) {
        _numberOfPages = numberOfPages;
        _displayPages = displayPages;
        _selctedTintColor = selctedTintColor;
        _unselctedTintColor = unselctedTintColor;
    }
    return self;
}

@end

@interface ACRPageControl()

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong, nullable) ACRPageControlConfig *config;

@end

@implementation ACRPageControl

-(instancetype) initWithConfig:(ACRPageControlConfig *)config
{
    self = [super initWithFrame:CGRectZero];
    _config = config;
    self.backgroundColor = [UIColor clearColor];
    
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.contentMode = UIViewContentModeRedraw;
    return self;
}

// Properties

- (CGSize)contentSize {
    CGFloat height = 10;
    return CGSizeMake(self.requiredLength, height);
}

- (CGSize)intrinsicContentSize {
    return self.shouldBeHidden ? CGSizeZero : [self contentSize];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self contentSize];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        [self render];
    }
}

- (void)setConfig:(nullable ACRPageControlConfig *)config {
    _config = config;
    [self render];
}

// Accessibility

// Private methods

- (BOOL)shouldBeHidden {
    return self.config.numberOfPages == 0 || (self.config.hidesForSinglePage.boolValue && self.config.numberOfPages == 1) || self.config == nil;
}

- (CGFloat)requiredLength {
    if (self.shouldBeHidden) return 0.0;
    CGFloat diameterSum = (self.displayPages - 1) * 6 + 10;
    return diameterSum + MAX(0.0, (self.displayPages - 1)) *7;
}

- (NSInteger)numberOfPages {
    return self.config.numberOfPages;
}

- (NSInteger)displayPages {
    if (self.config.displayPages) {
        return MIN(self.config.displayPages.integerValue, self.config.numberOfPages);
    }
    return self.config.numberOfPages;
}

// Drawing

- (void)drawRect:(CGRect)rect {
    if (self.shouldBeHidden) return;
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    NSInteger currentPage = MIN(MAX(self.currentPage, 0), self.numberOfPages - 1);

    NSRange displayRange;
    BOOL leadingHalfSize = NO;
    BOOL trailingHalfSize = NO;

    if (self.config.displayPages && self.config.displayPages.integerValue < self.numberOfPages) {
        NSInteger adjustedPage = (NSInteger)((currentPage + 1) / 3) * 3;
        NSInteger halfDisplayPages = self.config.displayPages.integerValue / 2;
        
        if (currentPage <= halfDisplayPages) {
            displayRange = NSMakeRange(0, self.config.displayPages.integerValue);
        } else if (adjustedPage >= self.numberOfPages - halfDisplayPages) {
            displayRange = NSMakeRange(self.numberOfPages - self.config.displayPages.integerValue, self.config.displayPages.integerValue);
        } else {
            displayRange = NSMakeRange(adjustedPage - halfDisplayPages, self.config.displayPages.integerValue);
        }
        
        leadingHalfSize = currentPage - halfDisplayPages > 0;
        trailingHalfSize = currentPage + halfDisplayPages < self.numberOfPages;
    } else {
        displayRange = NSMakeRange(0, self.numberOfPages);
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGPoint point = CGPointMake( floor((self.bounds.size.width - self.requiredLength) / 2.0 ), 0.0);
    
    for (NSInteger i = displayRange.location; i < NSMaxRange(displayRange); i++) {
        BOOL isSelectedPage = (i == currentPage);
        CGFloat diameter = isSelectedPage ? 10 : 6;
        
        point.y = floor((self.bounds.size.height - diameter) / 2.0);
        
        CGContextSetFillColorWithColor(context, (isSelectedPage ? self.config.selctedTintColor.CGColor: self.config.unselctedTintColor.CGColor));
        
        if ((leadingHalfSize && i == displayRange.location) || (trailingHalfSize && i == NSMaxRange(displayRange) - 1)) {
            CGContextFillEllipseInRect(context, CGRectMake(point.x + diameter / 4, point.y + diameter / 4, diameter / 2, diameter / 2));
        } else {
            CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, diameter, diameter));
        }
        
        CGFloat offset =  7 + diameter;
 
        point.x += offset;
    }
}

// Rendering

- (void)render {
    self.hidden = self.shouldBeHidden;
    [self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

@end
