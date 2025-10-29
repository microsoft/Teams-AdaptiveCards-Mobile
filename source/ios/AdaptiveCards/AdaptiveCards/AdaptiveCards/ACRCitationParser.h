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
- (instancetype)initWithDelegate:(id<ACRCitationParserDelegate> _Nullable)delegate;

/**
 * Abstract method to parse an attributed string and return a new one with citation attachments
 * Subclasses must override this method
 * @param attributedString The input attributed string to parse
 * @param references Array of reference dictionaries for citations
 * @return A new attributed string with citations replaced by text attachments
 */
- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<NSDictionary *> *)references;

/**
 * Abstract method to extract citation data from the input
 * Subclasses must override this method  
 * @param attributedString The input attributed string to parse
 * @return Array of dictionaries containing citation data (displayText, referenceId)
 */
- (NSArray<NSDictionary *> *)extractCitationData:(NSAttributedString *)attributedString;

/**
 * Concrete method to create a citation pill with reference data
 * @param citationData Dictionary containing displayText and referenceId
 * @param referenceData Dictionary containing the full reference information
 * @return ACRViewTextAttachment containing the citation button
 */
- (ACRViewTextAttachment *)createCitationPillWithData:(NSDictionary *)citationData 
                                        referenceData:(NSDictionary *)referenceData;

@end

NS_ASSUME_NONNULL_END
