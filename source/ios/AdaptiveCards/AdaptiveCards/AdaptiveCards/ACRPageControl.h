//
//  ACRPageIndicator.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 12/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// Configuration object
@interface ACRPageControlConfig : NSObject

- (instancetype _Nonnull)initWithNumberOfPages:(NSInteger)numberOfPages
                         displayPages:(nullable NSNumber *)displayPages
                              selctedTintColor:(UIColor *_Nonnull)selctedTintColor
                            unselctedTintColor:(UIColor *_Nonnull)unselctedTintColor;

@end

// PageControl interface
@interface ACRPageControl : UIView

-(instancetype _Nonnull ) initWithConfig:(ACRPageControlConfig *_Nonnull)config;
- (void)setCurrentPage:(NSInteger)currentPage;

@end
