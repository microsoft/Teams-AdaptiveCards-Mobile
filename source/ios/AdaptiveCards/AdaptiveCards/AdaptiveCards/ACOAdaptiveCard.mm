//
//  ACOAdaptiveCard.mm
//  ACOAdaptiveCard.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAdaptiveCardPrivate.h"
#import "ACOAuthenticationPrivate.h"
#import "ACOBundle.h"
#import "ACORefreshPrivate.h"
#import "ACORemoteResourceInformationPrivate.h"
#import "ACRErrors.h"
#import "ACRIBaseInputHandler.h"
#import "ACRParseWarningPrivate.h"
#import "AdaptiveCardParseException.h"
#import "AdaptiveCardParseWarning.h"
#import "ParseResult.h"
#import "SharedAdaptiveCard.h"
#import "UtiliOS.h"
#import <Foundation/Foundation.h>

using namespace AdaptiveCards;

@implementation ACOAdaptiveCard {
    std::shared_ptr<AdaptiveCard> _adaptiveCard;
    NSMutableArray<ACRIBaseInputHandler> *_inputs;
}

- (void)setInputs:(NSArray *)inputs
{
    _inputs = [[NSMutableArray<ACRIBaseInputHandler> alloc] initWithArray:inputs];
}

- (void)appendInputs:(NSArray *)inputs
{
    [_inputs addObjectsFromArray:inputs];
}

- (NSData *)inputs
{
    if (_inputs) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        for (id<ACRIBaseInputHandler> input in _inputs) {
            [input getInput:dictionary];
        }

        return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    }

    return nil;
}

- (NSArray<ACRIBaseInputHandler> *)getInputs
{
    return _inputs;
}

+ (NSString *)correctInvalidJsonEscapes:(NSString *)payload {
    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\\\+\\.)"
                                                                           options:0
                                                                             error:&regexError];
    if (regexError != nil) {
        NSLog(@"Regex Error: %@", regexError.localizedDescription);
        return payload; // Return the original payload if regex creation fails
    }
    
    NSMutableString *mutablePayload = [payload mutableCopy];

    // Replace matches with the correct number of escaped backslashes
    [regex enumerateMatchesInString:payload
                            options:0
                              range:NSMakeRange(0, payload.length)
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        if (match.range.length > 0) {
            NSString *matchedString = [payload substringWithRange:match.range];
            NSString *replacementString = [matchedString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            [mutablePayload replaceCharactersInRange:match.range withString:replacementString];
        }
    }];

    return [mutablePayload copy];
}

+ (BOOL)isValidJson:(NSString *)jsonString error:(NSError **)error {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return NO;
    }

    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    return (*error == nil);
}


+ (ACOAdaptiveCardParseResult *)fromJson:(NSString *)payload {
    const std::string g_version = "1.6";
    ACOAdaptiveCardParseResult *result = nil;
    if (payload) {
        NSError *jsonError = nil;

        // First, check if the JSON is valid
        if (![self isValidJson:payload error:&jsonError]) {
            NSLog(@"Initial JSON Deserialization Error: %@", jsonError.localizedDescription);
            jsonError = nil;

            // Attempt to fix the JSON using regex replacement
            NSString *processedPayload = [self correctInvalidJsonEscapes:payload];

            // Check if the corrected JSON is valid
            if (![self isValidJson:processedPayload error:&jsonError]) {
                NSLog(@"JSON Deserialization Error after fix: %@", jsonError.localizedDescription);
                return result; // Return nil result if JSON is still invalid
            }

            // Update payload to the corrected version
            payload = processedPayload;
        }

        // If JSON is valid or fixed, convert to NSData
        NSData *jsonData = [payload dataUsingEncoding:NSUTF8StringEncoding];

        // Deserialize JSON data to NSDictionary/NSArray
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];

        if (jsonObject != nil) {
            // Re-serialize the object to JSON data
            jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&jsonError];
            if (jsonError == nil && jsonData != nil) {
                // Convert back to NSString
                NSString *escapedPayload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                try {
                    ACOAdaptiveCard *card = [[ACOAdaptiveCard alloc] init];
                    std::shared_ptr<ParseResult> parseResult = AdaptiveCard::DeserializeFromString(std::string([escapedPayload UTF8String]), g_version);
                    NSMutableArray *acrParseWarnings = [[NSMutableArray alloc] init];
                    std::vector<std::shared_ptr<AdaptiveCardParseWarning>> parseWarnings = parseResult->GetWarnings();
                    for (const auto &warning : parseWarnings) {
                        ACRParseWarning *acrParseWarning = [[ACRParseWarning alloc] initWithParseWarning:warning];
                        [acrParseWarnings addObject:acrParseWarning];
                    }
                    card->_adaptiveCard = parseResult->GetAdaptiveCard();
                    if (card && card->_adaptiveCard) {
                        card->_refresh = [[ACORefresh alloc] init:card->_adaptiveCard->GetRefresh()];
                        card->_authentication = [[ACOAuthentication alloc] init:card->_adaptiveCard->GetAuthentication()];
                    }
                    result = [[ACOAdaptiveCardParseResult alloc] init:card errors:nil warnings:acrParseWarnings];
                } catch (const AdaptiveCardParseException &e) {
                    // Converts AdaptiveCardParseException to NSError
                    ErrorStatusCode errorStatusCode = e.GetStatusCode();
                    NSInteger errorCode = (long)errorStatusCode;
                    NSBundle *adaptiveCardsBundle = [[ACOBundle getInstance] getBundle];
                    NSString *localizedFormat = NSLocalizedStringFromTableInBundle(@"AdaptiveCards.Parsing", nil, adaptiveCardsBundle, "Parsing Error Messages");
                    NSString *objectModelErrorCodeInString = [NSString stringWithCString:ErrorStatusCodeToString(errorStatusCode).c_str() encoding:NSUTF8StringEncoding];
                    NSDictionary<NSErrorUserInfoKey, id> *userInfo = @{NSLocalizedDescriptionKey : [NSString localizedStringWithFormat:localizedFormat, objectModelErrorCodeInString]};
                    NSError *parseError = [NSError errorWithDomain:ACRParseErrorDomain
                                                              code:errorCode
                                                          userInfo:userInfo];
                    NSArray<NSError *> *errors = @[ parseError ];

                    result = [[ACOAdaptiveCardParseResult alloc] init:nil errors:errors warnings:nil];
                }
            } else {
                // Handle JSON serialization error
                NSLog(@"JSON Serialization Error: %@", jsonError.localizedDescription);
            }
        }
    }
    return result;
}

- (std::shared_ptr<AdaptiveCard> const &)card
{
    return _adaptiveCard;
}

- (void)setCard:(std::shared_ptr<AdaptiveCard> const &)card
{
    _adaptiveCard = card;
}

- (NSArray<ACORemoteResourceInformation *> *)remoteResourceInformation
{
    NSMutableArray *mutableRemoteResources = nil;
    std::vector<RemoteResourceInformation> remoteResourceVector = _adaptiveCard->GetResourceInformation();
    if (!remoteResourceVector.empty()) {
        mutableRemoteResources = [[NSMutableArray alloc] init];
        for (const auto &remoteResource : remoteResourceVector) {
            ACORemoteResourceInformation *remoteResourceObjc =
                [[ACORemoteResourceInformation alloc] initWithRemoteResourceInformation:remoteResource];
            if (remoteResourceObjc) {
                [mutableRemoteResources addObject:remoteResourceObjc];
            }
        }
        NSArray<ACORemoteResourceInformation *> *remoteResources = [NSArray arrayWithArray:mutableRemoteResources];
        return remoteResources;
    }
    return nil;
}

- (NSData *)additionalProperty
{
    if (_adaptiveCard) {
        Json::Value blob = _adaptiveCard->GetAdditionalProperties();
        if (blob.empty()) {
            return nil;
        }
        return JsonToNSData(blob);
    }
    return nil;
}

@end
