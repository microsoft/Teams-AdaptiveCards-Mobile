//
//  ACRCitationManager.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCitationManagerDelegate.h"
#import "ACOEnums.h"

@class ACOReference;
@class ACRView;
@class ACOCitation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Main manager class that acts as a class cluster for citation parsing and presentation.
 * Coordinates between different citation parsers and manages the presentation of citation details.
 * Also handles presenting the bottom sheet view controller when a citation pill is tapped
 */
@interface ACRCitationManager : NSObject

/**
 * The root view associated with this citation manager
 */
@property (nonatomic, strong) ACRView *rootView;

/**
 * Initialize the citation manager with a root view and delegate
 * @param rootView The ACRView instance that contains the citations
 * @param delegate The delegate that provides references and presentation context
 */
- (instancetype)initWithDelegate:(id<ACRCitationManagerDelegate>)delegate;

/**
 * Build interactive citations from an attributed string for TextBlock citations (regex-based pattern matching)
 * Used by ACRTextBlockRenderer to process text with "[1](cite:0)" style citations
 * This method also handles tap interactions for the citation pills
 * @param attributedString The input attributed string to build citations from
 * @param references Array of ACOReference objects for citations
 * @return A new attributed string with citations replaced by interactive text attachments
 */
- (NSAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString 
                                                references:(NSArray<ACOReference *> *)references;

/**
 * Build interactive citations from NSLink attributes in an attributed string
 * Specifically processes attributed strings that contain NSLinkAttributeName with "cite:" URLs
 * Used for TextBlock citations that have already been parsed into NSLink attributes
 * @param attributedString The input attributed string with NSLink attributes to process
 * @param references Array of ACOReference objects for citations
 * @return A new attributed string with citation links replaced by interactive text attachments
 */
- (NSAttributedString *)buildCitationsFromNSLinkAttributesInAttributedString:(NSAttributedString *)attributedString 
                                                                  references:(NSArray<ACOReference *> *)references;

/**
 * Build a single citation attachment from an ACOCitation object
 * Used for RichTextBlock CitationRun processing where citations are already parsed
 * @param citation ACOCitation object containing display text and reference index
 * @param references Array of ACOReference objects for citations
 * @return An attributed string containing the citation attachment
 */
- (NSAttributedString *)buildCitationAttachmentWithCitation:(ACOCitation *)citation
                                                 references:(NSArray<ACOReference *> *)references;

@end

NS_ASSUME_NONNULL_END
