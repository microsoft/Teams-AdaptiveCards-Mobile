//
//  ACRCitationManager.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCitationManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Main manager class that acts as a class cluster for citation parsing and presentation.
 * Coordinates between different citation parsers and manages the presentation of citation details.
 * Also handles presenting the bottom sheet view controller when a citation pill is tapped
 */
@interface ACRCitationManager : NSObject

/**
 * Initialize the citation manager with a delegate
 * @param delegate The delegate that provides references and presentation context
 */
- (instancetype)initWithDelegate:(nullable id<ACRCitationManagerDelegate>)delegate;

/**
 * Parse an attributed string for TextBlock citations (regex-based pattern matching)
 * Used by ACRTextBlockRenderer to process text with "[1](cite:0)" style citations
 * @param attributedString The input attributed string to parse
 * @param references Array of reference dictionaries for citations
 * @return A new attributed string with citations replaced by interactive text attachments
 */
- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<NSDictionary *> *)references;

/**
 * Parse an attributed string with embedded citation data for RichTextBlock
 * Used by ACRRichTextBlockRenderer to process text with embedded citation information
 * @param attributedString The input attributed string with citation data
 * @param references Array of reference dictionaries for citations
 * @return A new attributed string with citations replaced by interactive text attachments
 */
- (NSMutableAttributedString *)parseAttributedStringWithCitations:(NSAttributedString *)attributedString 
                                                   withReferences:(NSArray<NSDictionary *> *)references;

/**
 * Handle citation button taps - called by parsers when citation pills are tapped
 * @param sender The button that was tapped
 * @param citationData Dictionary containing citation information
 * @param referenceData Dictionary containing full reference information
 */
- (void)handleCitationTapped:(id)sender 
            withCitationData:(NSDictionary *)citationData 
               referenceData:(NSDictionary *)referenceData;

@end

NS_ASSUME_NONNULL_END
