//
//  ACOAdaptiveCard.h
//  ACOAdaptiveCard
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAuthentication.h"
#import "ACORefresh.h"
#import "ACORemoteResourceInformation.h"
#import "ACRIBaseInputHandler.h"
#else
/// Cocoapods Imports
#import <AdaptiveCards/ACOAdaptiveCardParseResult.h>
#import <AdaptiveCards/ACOAuthentication.h>
#import <AdaptiveCards/ACORefresh.h>
#import <AdaptiveCards/ACORemoteResourceInformation.h>
#import <AdaptiveCards/ACRIBaseInputHandler.h>
#endif
#import <Foundation/Foundation.h>

@class SwiftAdaptiveCardParseResult;

@interface ACOAdaptiveCard : NSObject

@property ACORefresh *refresh;
@property ACOAuthentication *authentication;

/**
 * Parse an adaptive card from JSON string.
 * @param payload The JSON string to parse
 * @return An ACOAdaptiveCardParseResult object containing the parsed card and/or errors
 */
+ (ACOAdaptiveCardParseResult *)fromJson:(NSString *)payload;

/**
 * Enables or disables the Swift implementation for adaptive card parsing.
 * @param enabled YES to use Swift implementation, NO to use Objective-C/C++ implementation
 */
+ (void)setUseSwiftImplementation:(BOOL)enabled;

/**
 * Checks if the Swift implementation is currently enabled.
 * @return YES if Swift implementation is enabled, NO otherwise
 */
+ (BOOL)isSwiftImplementationEnabled;

/**
 * Checks if the Swift implementation is available in this build.
 * @return YES if Swift implementation is available, NO otherwise
 */
+ (BOOL)isSwiftImplementationAvailable;

- (NSData *)inputs;
- (NSArray<ACRIBaseInputHandler> *)getInputs;
- (void)setInputs:(NSArray *)inputs;
- (void)appendInputs:(NSArray *)inputs;
- (NSArray<ACORemoteResourceInformation *> *)remoteResourceInformation;
- (NSData *)additionalProperty;
- (SwiftAdaptiveCardParseResult *)swiftParseResult;

@end
