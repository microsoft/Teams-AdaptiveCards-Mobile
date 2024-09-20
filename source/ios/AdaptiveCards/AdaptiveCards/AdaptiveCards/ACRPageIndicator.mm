//
//  ACRPageIndicator.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 12/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRPageIndicator.h"

@implementation PageControlConfig

- (instancetype)initWithNumberOfPages:(NSInteger)numberOfPages
                         displayPages:(nullable NSNumber *)displayPages
                    hidesForSinglePage:(nullable NSNumber *)hidesForSinglePage
              accessibilityValueFormat:(nullable NSString *)accessibilityValueFormat {
    self = [super init];
    if (self) {
        _numberOfPages = numberOfPages;
        _displayPages = displayPages;
        _hidesForSinglePage = hidesForSinglePage;
        _accessibilityValueFormat = accessibilityValueFormat;
    }
    return self;
}

@end

@implementation PageControl

// Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.contentMode = UIViewContentModeRedraw;
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

- (void)setConfig:(nullable PageControlConfig *)config {
    _config = config;
    [self render];
}

// Accessibility

- (NSString *)accessibilityValue {
    if (self.config.numberOfPages > 0) {
        NSString *format = self.config.accessibilityValueFormat ?: NSLocalizedString(@"PageXofY", @"Format for a paging control. %1$@ is the current value, %2$@ is the max value");
        return [NSString stringWithFormat:format, @(self.currentPage + 1), @(self.config.numberOfPages)];
    }
    return [NSString stringWithFormat:@"%ld", (long)(self.currentPage + 1)];
}

- (void)accessibilityIncrement {
    if (self.config.accessibilityPageChange && self.config.numberOfPages > self.currentPage) {
        self.config.accessibilityPageChange(self.currentPage + 1);
    }
}

- (void)accessibilityDecrement {
    if (self.config.accessibilityPageChange && self.currentPage > 0) {
        self.config.accessibilityPageChange(self.currentPage - 1);
    }
}

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
        
        CGContextSetFillColorWithColor(context, (isSelectedPage ? [UIColor blueColor].CGColor: [UIColor redColor].CGColor ));
        
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
    BOOL isAccessible = (self.config.accessibilityPageChange != nil);
    self.isAccessibilityElement = isAccessible;
    self.accessibilityTraits = isAccessible ? UIAccessibilityTraitAdjustable : 0;
    self.hidden = self.shouldBeHidden;
    [self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}

// Stylesheet

- (void)didChangeAppearanceProxy {
    [self render];
}

@end
