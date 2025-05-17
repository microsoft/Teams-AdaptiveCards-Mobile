//
//  SwiftAdaptiveCardParser.m
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardParser.h"
// Import the generated Swift header
#import <AdaptiveCardsSwift/AdaptiveCardsSwift-Swift.h>

@implementation SwiftAdaptiveCardParser

static BOOL _swiftParserEnabled = NO;

+ (BOOL)isSwiftParserEnabled {
    return _swiftParserEnabled;
}

+ (void)enableSwiftParser:(BOOL)enabled {
    _swiftParserEnabled = enabled;
    
    [SwiftAdaptiveCardParserSwift enableSwiftParser:enabled];
    NSLog(@"Swift parser module found and enabled: %@", enabled ? @"YES" : @"NO");
}

+ (id)parseWithPayload:(NSString *)payload {
    if (!payload) {
        NSLog(@"Error: Cannot parse nil payload");
        return nil;
    }
    
    // If Swift module is available, use it directly
    NSLog(@"Attempting to use Swift parser bridge");
    id result = [SwiftAdaptiveCardBridgeParserSwift parseWithPayload:payload];
    if (result) {
        NSLog(@"Successfully parsed using Swift implementation");
        return result;
    } else {
        NSLog(@"Swift implementation failed to parse the payload");
    }
    
    return nil;
}

@end
