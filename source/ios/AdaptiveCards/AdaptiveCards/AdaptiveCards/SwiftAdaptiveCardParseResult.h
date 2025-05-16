//
//  SwiftAdaptiveCardParseResult.h
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A placeholder class for Swift parse results.
 * Until the Swift integration is complete, this provides a stub implementation.
 */
@interface SwiftAdaptiveCardParseResult : NSObject

/**
 * Array of warnings encountered during parsing.
 */
@property (nonatomic, readonly) NSArray *warnings;

/**
 * Creates a new instance with the given warnings.
 */
- (instancetype)initWithWarnings:(NSArray *)warnings;

@end

NS_ASSUME_NONNULL_END
