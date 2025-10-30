//
//  ACRCitationParser.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ACRCitationParserDelegate.h"

@class ACRViewTextAttachment;
@class ACOReference;
@class ACOCitation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Abstract base class for citation parsing strategies
 * Subclasses implement specific parsing logic for different input formats (TextBlock vs RichTextBlock)
 */
@interface ACRCitationParser : NSObject

@property (nonatomic, weak, nullable) id<ACRCitationParserDelegate> delegate;

/**
 * Initialize the parser with a delegate
 * @param delegate The delegate that will receive parsing events
 * @return Initialized parser instance
 */
- (instancetype)initWithDelegate:(id<ACRCitationParserDelegate>)delegate;

/**
 * Abstract method to parse an attributed string and return a new one with citation attachments
 * Subclasses must override this method
 * @param attributedString The input attributed string to parse
 * @param references Array of ACOReference objects for citations
 * @return A new attributed string with citations replaced by text attachments
 */
- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<ACOReference *> *)references;

/**
 * Concrete method to create a citation pill with reference data
 * @param citation ACOCitation object containing displayText and referenceIndex
 * @param referenceData ACOReference object containing the full reference information
 * @return ACRViewTextAttachment containing the citation button
 */
- (ACRViewTextAttachment *)createAttachmentWithCitation:(ACOCitation *)citation 
                                              referenceData:(ACOReference *)referenceData;

/**
 * Helper method to find a reference by its index in the references array
 * @param referenceId NSNumber containing the reference index
 * @param references Array of ACOReference objects to search through
 * @return ACOReference object if found, nil otherwise
 */
- (nullable ACOReference *)findReferenceByIndex:(NSNumber *)referenceId 
                                   inReferences:(NSArray<ACOReference *> *)references;

@end

NS_ASSUME_NONNULL_END
