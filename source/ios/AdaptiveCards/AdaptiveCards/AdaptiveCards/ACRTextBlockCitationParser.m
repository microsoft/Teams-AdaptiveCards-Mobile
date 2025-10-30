//
//  ACRTextBlockCitationParser.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRTextBlockCitationParser.h"
#import "ACRCitationManager.h"
#import "ACRViewTextAttachment.h"
#import "ACOReference.h"
#import "ACOCitation.h"

@interface ACRTextBlockCitationParser ()
// No private properties needed - delegation handled by base class
@end

@implementation ACRTextBlockCitationParser

- (NSArray<NSDictionary *> *)extractCitationData:(NSAttributedString *)attributedString {
    NSMutableArray<NSDictionary *> *citations = [NSMutableArray array];
    NSString *inputString = attributedString.string;
    
    // Regex pattern to match "[displayText](cite:referenceId)"
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[([^\\]]+)\\]\\(cite:([^)]+)\\)"
                                                                           options:0
                                                                             error:&error];
    
    if (error) {
        NSLog(@"Citation regex error: %@", error.localizedDescription);
        return citations;
    }
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:inputString
                                                              options:0
                                                                range:NSMakeRange(0, inputString.length)];
    
    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges >= 3) {
            NSRange displayTextRange = [match rangeAtIndex:1];
            NSRange referenceIdRange = [match rangeAtIndex:2];
            
            NSString *displayText = [inputString substringWithRange:displayTextRange];
            NSString *referenceId = [inputString substringWithRange:referenceIdRange];
            
            NSDictionary *citationData = @{
                @"displayText": displayText,
                @"referenceId": referenceId
            };
            [citations addObject:citationData];
        }
    }
    
    return citations;
}

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString
                                      withReferences:(NSArray<ACOReference *> *)references
{
    NSMutableAttributedString *result = [attributedString mutableCopy];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray<NSDictionary *> *replacements = [NSMutableArray array];

    // First: collect all matches
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop) {
        id linkValue = attrs[NSLinkAttributeName];
        NSString *linkString = nil;
        
        if ([linkValue isKindOfClass:[NSURL class]]) {
            linkString = [(NSURL *)linkValue absoluteString];
        } else if ([linkValue isKindOfClass:[NSString class]]) {
            linkString = (NSString *)linkValue;
        }
        
        if ([linkString hasPrefix:@"cite:"]) {
            NSNumber *referenceId = [formatter numberFromString:[linkString substringFromIndex:5]];
            NSString *displayText = [[attributedString attributedSubstringFromRange:range] string];
            displayText = [displayText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:displayText
                                                             referenceIndex:referenceId];
            
            // Find matching reference data by index
            ACOReference *referenceData = nil;
            NSInteger referenceIndex = [referenceId integerValue];
            if (referenceIndex >= 0 && referenceIndex < references.count)
            {
                referenceData = references[referenceIndex];
            }
            
            ACRViewTextAttachment *citationPill = [self createCitationPillWithData:citation
                                                                     referenceData:referenceData];
            NSAttributedString *attachmentString =
                [NSAttributedString attributedStringWithAttachment:citationPill];
            
            // Store replacement info
            [replacements addObject:@{
                @"range" : [NSValue valueWithRange:range],
                @"attachment" : attachmentString
            }];
        }
    }];

    // Second: apply replacements (reverse order so ranges stay valid)
    for (NSDictionary *item in [replacements reverseObjectEnumerator]) {
        NSRange range = [item[@"range"] rangeValue];
        NSAttributedString *attachment = item[@"attachment"];
        [result replaceCharactersInRange:range withAttributedString:attachment];
    }

    return result;
}

@end
