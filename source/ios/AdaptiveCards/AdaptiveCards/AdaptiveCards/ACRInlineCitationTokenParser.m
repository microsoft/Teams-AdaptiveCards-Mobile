//
//  ACRInlineCitationTokenParser.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRInlineCitationTokenParser.h"
#import "ACRCitationManager.h"
#import "ACRViewTextAttachment.h"
#import "ACOReference.h"
#import "ACOCitation.h"

@interface ACRInlineCitationTokenParser ()
// No private properties needed - delegation handled by base class
@end

@implementation ACRInlineCitationTokenParser

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<ACOReference *> *)references {
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
            
            // Convert referenceId to NSNumber for ACOCitation
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSNumber *referenceIndex = [formatter numberFromString:referenceId];
            if (!referenceIndex) {
                referenceIndex = @0; // Default to 0 if parsing fails
            }
            
            // Create ACOCitation object
            ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:displayText
                                                             referenceIndex:referenceIndex];
            
            // Find matching reference data by index using helper method
            ACOReference *referenceData = [self findReferenceByIndex:referenceIndex inReferences:references];
            
            // Create citation button with both citation and reference data
            ACRViewTextAttachment *citationPill = [self createCitationAttachmentWithData:citation 
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
