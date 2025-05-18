//
//  SwiftAdaptiveCardParserBridge.h
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwiftAdaptiveCardObjcBridge : NSObject

+ (NSMutableArray *)getWarningsFromParseResult:(id)parseResult useSwift:(BOOL)useSwift;

@end
