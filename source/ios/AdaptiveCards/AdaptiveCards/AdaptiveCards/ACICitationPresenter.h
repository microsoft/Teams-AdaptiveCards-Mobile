//
//  ACICitationPresenter.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 25/03/26.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ACOCitation.h"
#import "ACOReference.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Public protocol for presenting citation bottom sheets.
 * Adopt this protocol to present citation reference details without depending on internal implementation.
 */
@protocol ACICitationPresenter <NSObject>

/**
 * Presents the citation reference bottom sheet for a given citation and reference.
 * Web-rendering path: caller has already resolved the active view controller.
 * @param activeController The view controller from which to present the sheet
 * @param citation The citation that was tapped
 * @param referenceData The reference data for the citation
 */
- (void)presentBottomSheetFrom:(UIViewController *)activeController
                didTapCitation:(ACOCitation *)citation
                 referenceData:(ACOReference * _Nullable)referenceData;

@optional

/**
 * Native card path: called by ACRCitationBuilder when a parser tap fires.
 * The conformer resolves the active UIViewController from its own stored actionDelegate.
 * @param citation The citation that was tapped
 * @param referenceData The reference data for the citation
 */
- (void)handleCitationTap:(ACOCitation *)citation
            referenceData:(ACOReference * _Nullable)referenceData;

@end

NS_ASSUME_NONNULL_END
