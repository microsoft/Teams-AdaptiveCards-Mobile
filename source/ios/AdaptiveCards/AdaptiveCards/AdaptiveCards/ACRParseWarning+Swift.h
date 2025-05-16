//
//  ACRParseWarning+Swift.h
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRParseWarningPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACRParseWarning (Swift)

/**
 * Creates a new parse warning with the given status code and reason.
 */
+ (instancetype)createWithStatusCode:(unsigned int)statusCode reason:(NSString *)reason;

@end

NS_ASSUME_NONNULL_END
