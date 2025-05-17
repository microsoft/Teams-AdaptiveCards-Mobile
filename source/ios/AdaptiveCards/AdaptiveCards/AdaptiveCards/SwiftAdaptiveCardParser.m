//
//  SwiftAdaptiveCardParser.m
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardParser.h"

@implementation SwiftAdaptiveCardParser

static BOOL _swiftParserEnabled = NO;

+ (BOOL)isSwiftParserEnabled {
    return _swiftParserEnabled;
}

+ (void)enableSwiftParser:(BOOL)enabled {
    _swiftParserEnabled = enabled;
    
    // Also try to update the Swift bridge directly if available
    Class bridgeParserClass = NSClassFromString(@"SwiftAdaptiveCardBridgeParserSwift");
    if (bridgeParserClass && [bridgeParserClass respondsToSelector:@selector(enableSwiftParser:)]) {
        [bridgeParserClass performSelector:@selector(enableSwiftParser:) withObject:@(enabled)];
    }
}

+ (id)parseWithPayload:(NSString *)payload {
    if (!payload) {
        NSLog(@"Error: Cannot parse nil payload");
        return nil;
    }
    
    // Try to use the Swift implementation via the bridge
//    SwiftAdaptiveCardBridgeParserSwift *bridgeParserClass;
    Class bridgeParserClass = NSClassFromString(@"SwiftAdaptiveCardBridgeParserSwift");
    if (bridgeParserClass && [bridgeParserClass respondsToSelector:@selector(parseWithPayload:)]) {
        id result = [bridgeParserClass performSelector:@selector(parseWithPayload:) withObject:payload];
        if (result) {
            NSLog(@"Successfully parsed using Swift implementation");
            return result;
        } else {
            NSLog(@"Swift implementation failed to parse the payload");
        }
    } else {
        NSLog(@"Swift bridge not available - import AdaptiveCardsSwift module to enable Swift parsing");
    }
    
    return nil;
}

@end
