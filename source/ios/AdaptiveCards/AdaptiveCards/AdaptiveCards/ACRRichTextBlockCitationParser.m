//
//  ACRRichTextBlockCitationParser.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRRichTextBlockCitationParser.h"
#import "ACOReference.h"
#import "ACOCitation.h"
@implementation ACRRichTextBlockCitationParser

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString
                                      withReferences:(NSArray<ACOReference *> *)references {
    // TODO: Implement RichTextBlock citation parsing
    // This will be implemented later when we focus on RichTextBlock
    return [attributedString mutableCopy];
}
//
//- (NSAttributedString *)parseAttributedStringWithCitation:(ACOCitation *)citation
//                                            andReferences:(NSArray<ACOReference *> *)references {
//    // Create citation attachment tausing the parser method
//    NSAttributedString *attachmentString = [super parseAttributedStringWithCitation:citation
//                                                                     andReferences:references];
//    
//    // Create text attachment with the button
//    NSString *str = [NSString stringWithFormat:@"_%@_", citation.displayText];
//    
//    NSMutableAttributedString *matttr = [[NSMutableAttributedString alloc] initWithString:str];
//    [matttr appendAttributedString:attachmentString];
//
//    return matttr;
//}

@end
