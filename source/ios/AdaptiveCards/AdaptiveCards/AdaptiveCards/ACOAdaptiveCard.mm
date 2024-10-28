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

    // Regex pattern to find each "regex": "..." entry with capturing groups for before, regex string, and after
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\"regex\"\\s*:\\s*\")(.*?)(\")"
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&regexError];

    if (regexError != nil) {
        NSLog(@"Regex Error: %@", regexError.localizedDescription);
        return payload; // Return the original payload if regex creation fails
    }

    NSMutableString *mutablePayload = [payload mutableCopy];

    // Enumerate over each regex match and correct backslashes incrementally
    __block NSInteger offset = 0; // Track adjustments to the range after replacements
    [regex enumerateMatchesInString:payload
                            options:0
                              range:NSMakeRange(0, payload.length)
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        if (match.numberOfRanges == 4) { // Ensure we have all 4 capturing groups
            // Adjust ranges by offset to account for previous replacements
            NSRange fullMatchRange = NSMakeRange(match.range.location + offset, match.range.length);
            NSRange regexStringRange = NSMakeRange([match rangeAtIndex:2].location + offset, [match rangeAtIndex:2].length);

            // Validate ranges to prevent out-of-bounds errors
            if (NSLocationInRange(regexStringRange.location, NSMakeRange(0, mutablePayload.length)) &&
                NSLocationInRange(NSMaxRange(regexStringRange), NSMakeRange(0, mutablePayload.length))) {
                
                // Extract the regex string
                NSString *regexString = [mutablePayload substringWithRange:regexStringRange];

                // Correct escaping: Replace each single backslash with two backslashes
                NSString *correctedRegexString = [regexString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];

                // Reconstruct the corrected full regex entry
                NSString *correctedFullEntry = [NSString stringWithFormat:@"%@%@%@", [payload substringWithRange:[match rangeAtIndex:1]], correctedRegexString, [payload substringWithRange:[match rangeAtIndex:3]]];

                // Replace the entire match with the corrected entry
                [mutablePayload replaceCharactersInRange:fullMatchRange withString:correctedFullEntry];

                // Update offset by the difference in length between corrected and original entries
                offset += correctedFullEntry.length - fullMatchRange.length;
            }
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
            // Attempt to fix the JSON using regex replacement
            NSString *processedPayload = [self correctInvalidJsonEscapes:payload];
            // Update payload to the corrected version
            payload = processedPayload;
        }

        // Use the already validated JSON object without re-serialization
        try {
            ACOAdaptiveCard *card = [[ACOAdaptiveCard alloc] init];
            std::shared_ptr<ParseResult> parseResult = AdaptiveCard::DeserializeFromString(std::string([payload UTF8String]), g_version);
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
