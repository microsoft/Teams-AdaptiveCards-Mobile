//
//  ACRPageIndicator.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 12/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// Configuration object
@interface PageControlConfig : NSObject

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign, nullable) NSNumber *displayPages;
@property (nonatomic, assign, nullable) NSNumber *hidesForSinglePage;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, UIColor *> *pageIndicatorTintColor;
@property (nonatomic, assign, nullable) NSNumber *isVertical;
@property (nonatomic, strong, nullable) NSString *accessibilityValueFormat;
@property (nonatomic, copy, nullable) void (^accessibilityPageChange)(NSInteger newPage);

- (instancetype _Nonnull)initWithNumberOfPages:(NSInteger)numberOfPages
                         displayPages:(nullable NSNumber *)displayPages
                       hidesForSinglePage:(nullable NSNumber *)hidesForSinglePage
             accessibilityValueFormat:(nullable NSString *)accessibilityValueFormat;

@end

// PageControl interface
@interface PageControl : UIView

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong, nullable) PageControlConfig *config;

@end

