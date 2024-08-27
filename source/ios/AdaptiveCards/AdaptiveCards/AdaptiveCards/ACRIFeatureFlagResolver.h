//
//  ACRIFeatureFlagResolver.h
//  AdaptiveCards
//
//  Created by Abhishek on 26/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACRIFeatureFlagResolver <NSObject>

- (BOOL)boolForFlag:(NSString *)flag;
- (NSString *)stringForFlag:(NSString *)flag;
- (NSNumber *)numberForFlag:(NSString *)flag;
- (NSArray *)arrayForFlag:(NSString *)flag;
- (NSDictionary *)dictForFlag:(NSString *)flag;

@end
