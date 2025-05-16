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
#import "ACRParseWarning+Swift.h"
#import "UtiliOS.h"

using namespace AdaptiveCards;

@implementation SwiftAdaptiveCardObjcBridge

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift {
    NSMutableArray *acrParseWarnings = [[NSMutableArray alloc] init];
    if (useSwift && parseResult != nil) {
        // Extract warnings directly from the Swift result object using KVC or respondsToSelector
        if ([parseResult respondsToSelector:@selector(warnings)]) {
            NSArray *swiftWarnings = [parseResult warnings];
            if (swiftWarnings) {
                // Convert each Swift warning to an ACRParseWarning
                for (id warning in swiftWarnings) {
                    NSInteger statusCode = 0;
                    NSString *reason = @"Unknown warning";
                    
                    // Try to get the status code and reason - first with direct properties
//                    if ([warning respondsToSelector:@selector(statusCode)]) {
//                        statusCode = [warning statusCode];
//                    } else if ([warning respondsToSelector:@selector(getStatusCode)]) {
//                        statusCode = [warning getStatusCode];
//                    }
//                    
//                    if ([warning respondsToSelector:@selector(reason)]) {
//                        reason = [warning reason];
//                    } else if ([warning respondsToSelector:@selector(getReason)]) {
//                        reason = [warning getReason];
//                    }
                    
                    // Create ACRParseWarning from Swift warning data
                    ACRParseWarning *acrWarning = [ACRParseWarning createWithStatusCode:(unsigned int)statusCode 
                                                                                reason:reason];
                    [acrParseWarnings addObject:acrWarning];
                }
            }
        }
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

@end
