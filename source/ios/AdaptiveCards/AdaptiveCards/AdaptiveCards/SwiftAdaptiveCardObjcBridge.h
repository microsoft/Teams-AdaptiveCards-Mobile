//
//  SwiftAdaptiveCardParserBridge.h
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SwiftAdaptiveCardParseResult;

// Protocol-based definitions for Swift classes to provide backward compatibility
// This allows the Objective-C code to compile even if the Swift header is not found at compile time
//@protocol SwiftAdaptiveCardParseResultProtocol <NSObject>
//@property (nullable, nonatomic, strong) id parseResult;
//@property (nullable, nonatomic, strong) NSArray<NSError *> *errors;
//@property (nullable, nonatomic, strong) NSArray *warnings;
//@end
//
//@protocol SwiftAdaptiveCardParserProtocol <NSObject>
//+ (BOOL)isSwiftParserEnabled;
//+ (void)setSwiftParserEnabled:(BOOL)enabled;
//+ (id<SwiftAdaptiveCardParseResultProtocol> _Nullable)parseWithPayload:(NSString *)payload;
//@end
//
//// Forward declaration with protocol conformance
//@interface SwiftAdaptiveCardParseResult : NSObject <SwiftAdaptiveCardParseResultProtocol>
//@end
//
//@interface SwiftAdaptiveCardParser : NSObject <SwiftAdaptiveCardParserProtocol>
//@end

@interface SwiftAdaptiveCardObjcBridge : NSObject

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift;

// Swift parser interface methods
+ (BOOL)isSwiftParserEnabled;
+ (void)setSwiftParserEnabled:(BOOL)enabled;
+ (SwiftAdaptiveCardParseResult * _Nullable)parseWithPayload:(NSString *)payload;

@end

NS_ASSUME_NONNULL_END
