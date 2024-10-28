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
