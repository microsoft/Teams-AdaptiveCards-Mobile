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
                                      withReferences:(NSArray<NSDictionary *> *)references {
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    NSString *inputString = attributedString.string;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\(cite:(.*?)\\)"
                                                                           options:0
                                                                             error:&error];
    
    if (error) {
        NSLog(@"Citation regex error: %@", error.localizedDescription);
        return result;
    }
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:inputString options:0 range:NSMakeRange(0, inputString.length)];
    
    // Process matches in reverse order to maintain correct ranges
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.numberOfRanges == 3) {
            NSString *displayText = [inputString substringWithRange:[match rangeAtIndex:1]];
            NSString *referenceId = [inputString substringWithRange:[match rangeAtIndex:2]];
            
            // Create citation data
            NSDictionary *citationData = @{
                @"displayText": displayText,
                @"referenceId": referenceId
            };
            
            // Find matching reference data by ID
            NSDictionary *referenceData = nil;
            for (NSDictionary *reference in references) {
                if ([reference[@"id"] isEqualToString:referenceId]) {
                    referenceData = reference;
                    break;
                }
            }
            
            // Create citation button with both citation and reference data
            ACRViewTextAttachment *citationPill = [self createCitationPillWithData:citationData 
                                                                      referenceData:referenceData];
            
            // Create text attachment with the button
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:citationPill];
            
            // Replace the [text](cite:id) with button
            NSRange fullMatchRange = match.range;
            [result replaceCharactersInRange:fullMatchRange withAttributedString:attachmentString];
        }
    }
    
    return result;
}

@end
