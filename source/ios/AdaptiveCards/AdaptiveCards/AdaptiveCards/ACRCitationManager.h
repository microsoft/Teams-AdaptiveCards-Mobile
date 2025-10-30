//
//  ACRCitationManager.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCitationManagerDelegate.h"

@class ACOReference;

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
- (instancetype)initWithDelegate:(id<ACRCitationManagerDelegate>)delegate;

/**
 * Build interactive citations from an attributed string for TextBlock citations (regex-based pattern matching)
 * Used by ACRTextBlockRenderer to process text with "[1](cite:0)" style citations
 * This method also handles tap interactions for the citation pills
 * @param attributedString The input attributed string to build citations from
 * @param references Array of ACOReference objects for citations
 * @return A new attributed string with citations replaced by interactive text attachments
 */
- (NSMutableAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString 
                                                       references:(NSArray<ACOReference *> *)references;

@end

NS_ASSUME_NONNULL_END
