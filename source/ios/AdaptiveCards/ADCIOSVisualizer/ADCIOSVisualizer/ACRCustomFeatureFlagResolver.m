//
//  ACRCustomFeatureFlagResolver.m
//  ADCIOSVisualizer
//
//  Created by Abhishek on 26/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCustomFeatureFlagResolver.h"

@implementation ACRCustomFeatureFlagResolver

static NSString *const isSplitButtonEnabledKey = @"isSplitButtonEnabled";
static NSString *const isProgressRingEnabledKey = @"isProgressRingEnabled";
static NSString *const isCitationsEnabledKey = @"isCitationsEnabled";
static NSString *const isStringResourceEnabledKey = @"isStringResourceEnabled";
static NSString *const isSwiftAdaptiveCardsEnabledKey = @"isSwiftAdaptiveCardsEnabled";

/// Check if Swift Adaptive Cards mode is enabled via launch argument
- (BOOL)isSwiftAdaptiveCardsEnabledViaLaunchArgument
{
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    return [arguments containsObject:@"--enable-swift-adaptive-cards"];
}

- (NSArray *)arrayForFlag:(NSString *)flag 
{
    return nil;
}

- (BOOL)boolForFlag:(NSString *)flag 
{
    if([flag isEqualToString:@"isFlowLayoutEnabled"])
    {
        return YES;
    }
    
    if([flag isEqualToString:@"isGridLayoutEnabled"])
    {
        return YES;
    }
    
    if([flag isEqualToString:isSplitButtonEnabledKey])
    {
        return YES;
    }
    
    if([flag isEqualToString:isCitationsEnabledKey])
    {
        return YES;
    }
    
    if([flag isEqualToString:isStringResourceEnabledKey])
    {
        return YES;
    }
    
    // Check for Swift Adaptive Cards flag - supports launch argument for UI testing
    if([flag isEqualToString:isSwiftAdaptiveCardsEnabledKey])
    {
        return [self isSwiftAdaptiveCardsEnabledViaLaunchArgument];
    }
    
    return NO;
}

- (NSDictionary *)dictForFlag:(NSString *)flag 
{
    return nil;
}

- (NSNumber *)numberForFlag:(NSString *)flag 
{
    return nil;
}

- (NSString *)stringForFlag:(NSString *)flag 
{
    if ([flag isEqualToString:@"fluentIconCdnURL"])
    {
        return @"https://res-1.cdn.office.net/assets/fluentui-react-icons/2.0.226/";
    }
    
    return nil;
}

@end
