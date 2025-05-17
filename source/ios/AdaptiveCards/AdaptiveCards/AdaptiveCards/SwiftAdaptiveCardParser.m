//
//  SwiftAdaptiveCardParser.m
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardParser.h"
#import <objc/runtime.h>

@implementation SwiftAdaptiveCardParser

static BOOL _swiftParserEnabled = NO;

+ (BOOL)isSwiftParserEnabled {
    // Check the actual Swift implementation if available
    Class bridgeParserClass = [self getBridgeParserClass];
    if (bridgeParserClass && [bridgeParserClass respondsToSelector:@selector(isSwiftParserEnabled)]) {
        // This will return the actual state from the Swift implementation
        return [[bridgeParserClass performSelector:@selector(isSwiftParserEnabled)] boolValue];
    }
    
    // Fallback to local state
    return _swiftParserEnabled;
}

+ (void)enableSwiftParser:(BOOL)enabled {
    _swiftParserEnabled = enabled;
    
    // Also try to update the Swift bridge directly if available
    Class bridgeParserClass = [self getBridgeParserClass];
    if (bridgeParserClass && [bridgeParserClass respondsToSelector:@selector(enableSwiftParser:)]) {
        [bridgeParserClass performSelector:@selector(enableSwiftParser:) withObject:@(enabled)];
    }
}

/**
 * Finds the bridge parser class using various methods.
 * First tries explicit class names, then looks for bundle by identifier, 
 * and finally tries to find the class in any loaded framework.
 */
+ (Class)getBridgeParserClass {
    // First try direct class name lookup
    Class bridgeClass = NSClassFromString(@"SwiftAdaptiveCardBridgeParserSwift");
    if (bridgeClass) {
        return bridgeClass;
    }
    
    // Try with module name prefix
    bridgeClass = NSClassFromString(@"AdaptiveCardsSwift.SwiftAdaptiveCardBridgeParserSwift");
    if (bridgeClass) {
        return bridgeClass;
    }
    
    // Try to find the bundle for AdaptiveCardsSwift framework
    NSBundle *swiftBundle = [NSBundle bundleWithIdentifier:@"com.microsoft.AdaptiveCardsSwift"];
    if (!swiftBundle) {
        // Try to find the bundle by searching for a known class in the framework
        // We use dynamic lookup of any class that might be in the AdaptiveCardsSwift framework
        for (NSString *possibleClass in @[@"SwiftAdaptiveCardParserSwift", @"AdaptiveCardSwift"]) {
            Class knownClass = NSClassFromString(possibleClass);
            if (knownClass) {
                swiftBundle = [NSBundle bundleForClass:knownClass];
                if (swiftBundle) {
                    NSLog(@"Found Swift bundle: %@", swiftBundle.bundleIdentifier);
                    break;
                }
            }
        }
    }
    
    // If we found the bundle, try to load the class with the bundle's prefixes
    if (swiftBundle) {
        NSString *bundlePrefix = swiftBundle.infoDictionary[@"CFBundleName"];
        if (!bundlePrefix) {
            bundlePrefix = swiftBundle.infoDictionary[@"CFBundleExecutable"];
        }
        
        if (bundlePrefix) {
            NSString *fullClassName = [NSString stringWithFormat:@"%@.SwiftAdaptiveCardBridgeParserSwift", bundlePrefix];
            bridgeClass = NSClassFromString(fullClassName);
            if (bridgeClass) {
                NSLog(@"Found Swift bridge class using bundle prefix: %@", fullClassName);
                return bridgeClass;
            }
        }
    }
    
    NSLog(@"Swift bridge not available - import AdaptiveCardsSwift module to enable Swift parsing");
    return nil;
}

+ (id)parseWithPayload:(NSString *)payload {
    if (!payload) {
        NSLog(@"Error: Cannot parse nil payload");
        return nil;
    }
    
    // Try to use the Swift implementation via the bridge
    Class bridgeParserClass = [self getBridgeParserClass];
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
