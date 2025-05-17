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

@interface SwiftAdaptiveCardObjcBridge : NSObject

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift;

// Swift parser interface methods
+ (BOOL)isSwiftParserEnabled;
+ (void)setSwiftParserEnabled:(BOOL)enabled;
+ (SwiftAdaptiveCardParseResult * _Nullable)parseWithPayload:(NSString *)payload;

@end

NS_ASSUME_NONNULL_END
