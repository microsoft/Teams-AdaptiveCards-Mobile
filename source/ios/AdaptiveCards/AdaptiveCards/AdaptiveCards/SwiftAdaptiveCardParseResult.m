//
//  SwiftAdaptiveCardParseResult.m
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardParseResult.h"

@interface SwiftAdaptiveCardParseResult()

@property (nonatomic, strong) NSArray *warnings;

@end

@implementation SwiftAdaptiveCardParseResult

- (instancetype)init {
    self = [super init];
    if (self) {
        _warnings = @[];
    }
    return self;
}

- (instancetype)initWithWarnings:(NSArray *)warnings {
    self = [super init];
    if (self) {
        _warnings = [warnings copy] ?: @[];
    }
    return self;
}

@end
