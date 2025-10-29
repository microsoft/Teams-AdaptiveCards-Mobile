//
//  ACRRichTextBlockCitationParser.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRRichTextBlockCitationParser.h"

@implementation ACRRichTextBlockCitationParser

- (NSArray<NSDictionary *> *)extractCitationData:(NSAttributedString *)attributedString {
    // TODO: Implement RichTextBlock citation extraction
    // This will be implemented later when we focus on RichTextBlock
    return @[];
}

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                          tapHandler:(void (^)(id sender, NSDictionary *citationData))tapHandler {
    // TODO: Implement RichTextBlock citation parsing
    // This will be implemented later when we focus on RichTextBlock
    return [attributedString mutableCopy];
}

@end