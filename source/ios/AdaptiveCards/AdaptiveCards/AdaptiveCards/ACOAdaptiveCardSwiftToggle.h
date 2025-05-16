//
//  ACOAdaptiveCardSwiftToggle.h
//  AdaptiveCards
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACOAdaptiveCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACOAdaptiveCard (SwiftToggle)

/**
 * Checks if the Swift implementation is available in this build.
 * @return YES if Swift implementation is available, NO otherwise
 */
+ (BOOL)isSwiftImplementationAvailable;

@end

NS_ASSUME_NONNULL_END
