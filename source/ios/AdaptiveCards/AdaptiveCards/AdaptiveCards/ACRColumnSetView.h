//
//  ACRColumnSetView
//  ACRColumnSetView.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//
#import "ACRContentStackView.h"

@class ACRColumnView;

@interface ACRColumnSetView : ACRContentStackView

@property BOOL isLastColumn;
@property BOOL hasMoreThanOneColumnWithRelatvieWidth;

/// Stores all columns with relative width constraints for visibility management
@property (nonatomic, strong, nullable) NSMutableArray<ACRColumnView *> *columnsWithRelativeWidth;

- (void)setAlignmentForColumnStretch;

/// Updates relative width constraints when column visibility changes.
/// Deactivates constraints referencing hidden columns and recreates them between visible columns.
- (void)updateRelativeWidthConstraintsForVisibilityChange;

@end
