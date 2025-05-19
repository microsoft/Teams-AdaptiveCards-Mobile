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

#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
#import <AdaptiveCards/AdaptiveCards-Swift.h>
#endif

using namespace AdaptiveCards;

@implementation SwiftAdaptiveCardObjcBridge

+ (BOOL)canUseSwift {
#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
    return YES;
#endif
    return NO;
}

+ (NSMutableArray * _Nullable)getWarningsFromParseResult:(id _Nullable)parseResult useSwift:(BOOL)useSwift {
    NSMutableArray *acrParseWarnings = [[NSMutableArray alloc] init];
    if (useSwift && [self canUseSwift]) {
        // Swift implementation
       SwiftAdaptiveCardParseResult *swiftResult = (SwiftAdaptiveCardParseResult *)parseResult;
//       NSArray *swiftWarnings = [swiftResult warnings];
//       if (swiftWarnings) {
//           acrParseWarnings = [NSMutableArray arrayWithArray:swiftWarnings];
//       }
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
    if ([self canUseSwift]) {
#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
        return [SwiftAdaptiveCardParser isSwiftParserEnabled];
#endif
    }
    return NO;
}

+ (void)setSwiftParserEnabled:(BOOL)enabled {
    if ([self canUseSwift]) {
#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
        [SwiftAdaptiveCardParser setSwiftParserEnabled:enabled];
#endif
    }
}

+ (SwiftAdaptiveCardParseResult * _Nullable)parseWithPayload:(NSString *_Nonnull)payload {
    if ([self canUseSwift]) {
#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
        return [SwiftAdaptiveCardParser parseWithPayload:payload];
#endif
    }
    return nil;
}


@end
