//
//  ACRErrors
//  ACRErrors.m
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRErrors.h"

NSString *const ACRInputErrorDomain = @"ACRInputErrorDomain";
NSString *const ACRParseErrorDomain = @"ACRParseErrorDomain";

@implementation ACOFallbackException

+ (ACOFallbackException *)fallbackException
{
    ACOFallbackException *fallbackException = [[ACOFallbackException alloc] init];
    return fallbackException;
}

@end

@implementation ACORootFallbackException

+ (ACORootFallbackException *)fallbackException
{
    ACORootFallbackException *fallbackException = [[ACORootFallbackException alloc] init];
    return fallbackException;
}

@end
