//
//  ACRCitationBuilder.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCitationBuilderDelegate.h"
#import "ACICitationPresenter.h"
#import "ACOEnums.h"

@class ACOReference;
@class ACOCitation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Builds NSAttributedString with interactive citation pill attachments.
 * Coordinates ACRInlineCitationTokenParser, ACRTextBlockCitationParser, and ACRCitationParser.
 * Does NOT handle any UIKit presentation — presentation is delegated to `presenter`.
 */
@interface ACRCitationBuilder : NSObject

/**
 * Initialize the citation builder with a delegate that receives analytics callbacks.
 * @param delegate The delegate that receives citation tap notifications
 */
- (instancetype)initWithDelegate:(id<ACRCitationBuilderDelegate>)delegate;

/**
 * Build interactive citations from an attributed string for TextBlock citations (regex-based pattern matching).
 */
- (NSAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString
                                                references:(NSArray<ACOReference *> *)references
                                                 presenter:(id<ACICitationPresenter>)presenter
                                                     theme:(ACRTheme)theme;

/**
 * Build interactive citations from NSLink attributes in an attributed string.
 */
- (NSAttributedString *)buildCitationsFromNSLinkAttributesInAttributedString:(NSAttributedString *)attributedString
                                                                  references:(NSArray<ACOReference *> *)references
                                                                   presenter:(id<ACICitationPresenter>)presenter
                                                                       theme:(ACRTheme)theme;

/**
 * Build a single citation attachment from an ACOCitation object.
 */
- (NSAttributedString *)buildCitationAttachmentWithCitation:(ACOCitation *)citation
                                                 references:(NSArray<ACOReference *> *)references
                                                  presenter:(id<ACICitationPresenter>)presenter;

@end

NS_ASSUME_NONNULL_END
