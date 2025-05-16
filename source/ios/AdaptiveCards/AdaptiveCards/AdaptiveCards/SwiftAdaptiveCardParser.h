//
//  SwiftAdaptiveCardParser.h
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A simple interface for interacting with Swift parser functionality.
 * For now, this is just a placeholder.
 */
@interface SwiftAdaptiveCardParser : NSObject

/**
 * Checks if the Swift parser is enabled.
 */
+ (BOOL)isSwiftParserEnabled;

/**
 * Enables or disables the Swift parser.
 */
+ (void)enableSwiftParser:(BOOL)enabled;

/**
 * Parses an adaptive card from JSON.
 */
+ (id _Nullable)parseWithPayload:(NSString *)payload;

@end

NS_ASSUME_NONNULL_END
