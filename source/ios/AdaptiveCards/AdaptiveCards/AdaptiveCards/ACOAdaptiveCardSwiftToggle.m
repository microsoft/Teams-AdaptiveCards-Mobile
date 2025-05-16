//
//  ACOAdaptiveCardSwiftToggle.m
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOAdaptiveCardSwiftToggle.h"

@implementation ACOAdaptiveCard (SwiftToggle)

+ (BOOL)isSwiftImplementationAvailable {
    // First check if the native Swift parser is available
    Class swiftParserClass = NSClassFromString(@"SwiftAdaptiveCardParser");
    if (swiftParserClass) {
        return YES;
    }
    
    // Then check if the bridge class is available
    Class bridgeClass = NSClassFromString(@"ACRAdaptiveCardSwiftBridge");
    if (bridgeClass) {
        return YES;
    }
    
    // If neither is available, return NO
    return NO;
}

@end
