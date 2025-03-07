//
//  SwiftAdaptiveCardParserBridge.h
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwiftAdaptiveCardObjcBridge : NSObject

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift;

@end

NS_ASSUME_NONNULL_END
