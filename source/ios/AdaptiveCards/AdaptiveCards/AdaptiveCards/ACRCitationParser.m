//
//  ACRCitationParser.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationParser.h"
#import "ACRCitationManager.h"
#import "ACRViewTextAttachment.h"
#import "ACOReference.h"
#import "ACOCitation.h"
#import <objc/runtime.h>
#import "ACRCitationParserDelegate.h"
@implementation ACRCitationParser

- (instancetype)initWithDelegate:(id<ACRCitationParserDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<ACOReference *> *)references {
    // Abstract method - subclasses must override
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSArray<NSDictionary *> *)extractCitationData:(NSAttributedString *)attributedString {
    // Abstract method - subclasses must override
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Shared Button Creation (Reusable by all parsers)

- (UIButton *)createButtonWithTitle:(NSString *)title size:(CGSize)size {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 4.0;
    button.layer.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1].CGColor;
    button.layer.borderColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1].CGColor;
    
    // Set button title font to regular size 14
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    
    // Ensure button can receive touches
    button.userInteractionEnabled = YES;
    
    // Add target for button tap
    [button addTarget:self action:@selector(citationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Shared Attachment Creation (Reusable by all parsers)

- (ACRViewTextAttachment *)createAttachmentWithCitation:(ACOCitation *)citation 
                                          referenceData:(ACOReference *)referenceData {
    if (!referenceData)
    {
        return nil;
    }
    NSString *text = citation.displayText;
    CGSize size = CGSizeMake(17, 17);
    
    // Create a UIButton with citation styling
    UIButton *citationButton = [self createButtonWithTitle:text size: size];
    
    // Store both citation data and reference data for retrieval in tap handler
    objc_setAssociatedObject(citationButton, @"citation", citation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(citationButton, @"referenceData", referenceData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Adjust width for long strings
    CGFloat newWidth = MAX(citationButton.titleLabel.intrinsicContentSize.width + 8.0, size.width);
    
    // Create the ACRViewTextAttachment with the button
    ACRViewTextAttachment *attachment = [[ACRViewTextAttachment alloc] initWithView:citationButton size:CGSizeMake(newWidth, size.height)];
    
    return attachment;
}

- (void)citationButtonTapped:(UIButton *)button {
    // Get stored citation and reference data
    ACOCitation *citation = objc_getAssociatedObject(button, @"citation");
    ACOReference *referenceData = objc_getAssociatedObject(button, @"referenceData");
    
    // Delegate back to the parser delegate
    if (self.delegate && citation) {
        [self.delegate citationParser:self didTapCitation:citation referenceData:referenceData];
    }
    
    //TODO
    
}

#pragma mark - Helper Methods

- (NSAttributedString *)parseAttributedStringWithCitation:(ACOCitation *)citation
                                            andReferences:(NSArray<ACOReference *> *)references {
    // Find matching reference data by index using helper method
    ACOReference *referenceData = [self findReferenceByIndex:citation.referenceIndex inReferences:references];
    
    // TextBlock citations use the default attributed string with attachment
    ACRViewTextAttachment *attachment = [self createAttachmentWithCitation:citation referenceData:referenceData];
    
    if(!attachment)
    {
        return [[NSAttributedString alloc] initWithString:citation.displayText];
    }
    
    // Create text attachment with the button
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    return attachmentString;
}


- (nullable ACOReference *)findReferenceByIndex:(NSNumber *)referenceId 
                                   inReferences:(NSArray<ACOReference *> *)references {
    
    if (!referenceId || !references) {
        return nil;
    }
    
    NSInteger referenceIndex = [referenceId integerValue];
    if (referenceIndex >= 0 && referenceIndex < references.count) {
        return references[referenceIndex];
    }
    
    return nil;
}

@end
