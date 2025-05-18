//
//  SwiftAdaptiveCardParserBridge.m
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardObjcBridge.h"

#import "SharedAdaptiveCard.h"
#import "ParseResult.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACRParseWarningPrivate.h"
#import "UtiliOS.h"

// Forward declarations for Swift classes
@class SwiftAdaptiveCardParseResult;
@class SwiftAdaptiveCardParser;

// Try different import methods to support various build environments
#if defined(COCOAPODS) || defined(ADAPTIVE_CARDS_USE_SWIFT)
    // CocoaPods environment
    #if __has_include(<SwiftAdaptiveCards/SwiftAdaptiveCards-Swift.h>)
        #import <SwiftAdaptiveCards/SwiftAdaptiveCards-Swift.h>
        #define SWIFT_HEADER_FOUND 1
    #elif __has_include("SwiftAdaptiveCards-Swift.h")
        #import "SwiftAdaptiveCards-Swift.h"
        #define SWIFT_HEADER_FOUND 1
    #else
        #define SWIFT_HEADER_FOUND 0
        #warning "SwiftAdaptiveCards Swift header not found at compile time. Will attempt runtime lookup."
    #endif
#else
    // Local development environment
    #if __has_include("SwiftAdaptiveCards-Swift.h")
        #import "SwiftAdaptiveCards-Swift.h"
        #define SWIFT_HEADER_FOUND 1
    #else
        #define SWIFT_HEADER_FOUND 0
        #warning "SwiftAdaptiveCards Swift header not found at compile time. Will attempt runtime lookup."
    #endif
#endif

// Utility function to get the module-aware class name
static NSString* getModuleAwareClassName(NSString *className) {
    // Try with different module prefixes
    NSArray *potentialClassNames = @[
        className,                        // No prefix (same process/module)
        [NSString stringWithFormat:@"SwiftAdaptiveCards.%@", className], // Module prefix
        [NSString stringWithFormat:@"_TtC17SwiftAdaptiveCards%lu%@", (unsigned long)className.length, className] // Swift mangled name format
    ];
    
    for (NSString *potentialName in potentialClassNames) {
        Class cls = NSClassFromString(potentialName);
        if (cls) {
            return potentialName;
        }
    }
    
    // If we couldn't find the class, log it and return the original className as fallback
    NSLog(@"[AdaptiveCards] Warning: Could not find Swift class '%@' at runtime with any known module prefixes", className);
    return className;
}

using namespace AdaptiveCards;

@implementation SwiftAdaptiveCardObjcBridge

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift {
    NSMutableArray *acrParseWarnings = [[NSMutableArray alloc] init];
    if (useSwift) {
#if SWIFT_HEADER_FOUND
        // Extract warnings from Swift parse result
        if ([parseResult isKindOfClass:[SwiftAdaptiveCardParseResult class]]) {
            SwiftAdaptiveCardParseResult *swiftResult = (SwiftAdaptiveCardParseResult *)parseResult;
            if (swiftResult.warnings) {
                acrParseWarnings = [NSMutableArray arrayWithArray:swiftResult.warnings];
            }
        }
#else
        // Try to find the SwiftAdaptiveCardParseResult class at runtime
        NSString *resultClassName = getModuleAwareClassName(@"SwiftAdaptiveCardParseResult");
        Class resultClass = NSClassFromString(resultClassName);
        
        if (resultClass && [parseResult isKindOfClass:resultClass]) {
            // Use KVC to get warnings property
            NSArray *warnings = [parseResult valueForKey:@"warnings"];
            if (warnings) {
                acrParseWarnings = [NSMutableArray arrayWithArray:warnings];
            } else {
                NSLog(@"[AdaptiveCards] Warning: Could not extract warnings property from SwiftAdaptiveCardParseResult at runtime");
            }
        } else {
            NSLog(@"[AdaptiveCards] Warning: Unexpected result type for Swift parse result");
        }
#endif
    } else {
        // For C++ implementation, check the type of parseResult
        if ([parseResult isKindOfClass:[NSValue class]]) {
            // If it's an NSValue (which can store C++ pointers), extract the pointer
            std::shared_ptr<ParseResult> *cppResultPtr = (std::shared_ptr<ParseResult> *)[parseResult pointerValue];
            std::vector<std::shared_ptr<AdaptiveCardParseWarning>> parseWarnings = (*cppResultPtr)->GetWarnings();
            for (const auto &warning : parseWarnings) {
                ACRParseWarning *acrParseWarning = [[ACRParseWarning alloc] initWithParseWarning:warning];
                [acrParseWarnings addObject:acrParseWarning];
            }
        } else {
            NSLog(@"Error retrieving parsed result");
        }
    }
    return acrParseWarnings;
}

+ (BOOL)isSwiftParserEnabled {
#if SWIFT_HEADER_FOUND
    return [SwiftAdaptiveCardParser isSwiftParserEnabled];
#else
    NSLog(@"[AdaptiveCards] Warning: SwiftAdaptiveCards-Swift.h not found at compile time, trying runtime lookup for SwiftAdaptiveCardParser");
    
    // Try to find the SwiftAdaptiveCardParser class at runtime
    NSString *className = getModuleAwareClassName(@"SwiftAdaptiveCardParser");
    Class parserClass = NSClassFromString(className);
    
    if (parserClass && [parserClass respondsToSelector:@selector(isSwiftParserEnabled)]) {
        // Use NSSelectorFromString to avoid compile-time checks on the selector
        SEL selector = NSSelectorFromString(@"isSwiftParserEnabled");
        NSMethodSignature *signature = [parserClass methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:parserClass];
        [invocation invoke];
        
        BOOL result = NO;
        [invocation getReturnValue:&result];
        return result;
    }
    
    return NO; // Disable Swift parser if the class or method can't be found
#endif
}

+ (void)setSwiftParserEnabled:(BOOL)enabled {
#if SWIFT_HEADER_FOUND
    [SwiftAdaptiveCardParser setSwiftParserEnabled:enabled];
#else
    NSLog(@"[AdaptiveCards] Warning: SwiftAdaptiveCards-Swift.h not found at compile time, trying runtime lookup for SwiftAdaptiveCardParser");
    
    // Try to find the SwiftAdaptiveCardParser class at runtime
    NSString *className = getModuleAwareClassName(@"SwiftAdaptiveCardParser");
    Class parserClass = NSClassFromString(className);
    
    if (parserClass && [parserClass respondsToSelector:@selector(setSwiftParserEnabled:)]) {
        // Use NSSelectorFromString to avoid compile-time checks on the selector
        SEL selector = NSSelectorFromString(@"setSwiftParserEnabled:");
        NSMethodSignature *signature = [parserClass methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:parserClass];
        [invocation setArgument:&enabled atIndex:2]; // First arg at index 2 (0: self, 1: _cmd)
        [invocation invoke];
    } else {
        NSLog(@"[AdaptiveCards] Error: SwiftAdaptiveCardParser class or setSwiftParserEnabled: method not found at runtime");
    }
#endif
}

+ (SwiftAdaptiveCardParseResult *)parseWithPayload:(NSString *)payload {
#if SWIFT_HEADER_FOUND
    return [SwiftAdaptiveCardParser parseWithPayload:payload];
#else
    NSLog(@"[AdaptiveCards] Warning: SwiftAdaptiveCards-Swift.h not found at compile time, trying runtime lookup for SwiftAdaptiveCardParser");
    
    // Try to find the SwiftAdaptiveCardParser class at runtime
    NSString *parserClassName = getModuleAwareClassName(@"SwiftAdaptiveCardParser");
    Class parserClass = NSClassFromString(parserClassName);
    
    if (parserClass && [parserClass respondsToSelector:@selector(parseWithPayload:)]) {
        // Find parseWithPayload: selector
        SEL parseSelector = NSSelectorFromString(@"parseWithPayload:");
        NSMethodSignature *parseSignature = [parserClass methodSignatureForSelector:parseSelector];
        NSInvocation *parseInvocation = [NSInvocation invocationWithMethodSignature:parseSignature];
        [parseInvocation setSelector:parseSelector];
        [parseInvocation setTarget:parserClass];
        [parseInvocation setArgument:&payload atIndex:2]; // First arg at index 2
        [parseInvocation invoke];
        
        // Get the return value
        __unsafe_unretained id result = nil;
        [parseInvocation getReturnValue:&result];
        
        // Check if return value is of expected type
        NSString *resultClassName = getModuleAwareClassName(@"SwiftAdaptiveCardParseResult");
        Class resultClass = NSClassFromString(resultClassName);
        
        if ([result isKindOfClass:resultClass]) {
            return result;
        } else if (result) {
            NSLog(@"[AdaptiveCards] Warning: parseWithPayload: returned an unexpected type: %@", [result class]);
        }
    } else {
        NSLog(@"[AdaptiveCards] Error: SwiftAdaptiveCardParser class or parseWithPayload: method not found at runtime");
    }
    
    // If we reached here, attempt to create a minimal SwiftAdaptiveCardParseResult
    NSString *resultClassName = getModuleAwareClassName(@"SwiftAdaptiveCardParseResult");
    Class resultClass = NSClassFromString(resultClassName);
    
    if (resultClass) {
        // Try to create a new instance
        id result = [[resultClass alloc] init];
        if (result) {
            NSLog(@"[AdaptiveCards] Created empty SwiftAdaptiveCardParseResult as fallback");
            return result;
        }
    }
    
    return nil; // Return nil if all attempts failed
#endif
}

@end
