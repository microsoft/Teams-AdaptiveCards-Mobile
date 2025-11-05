//
//  ACRCitationManager.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationManager.h"
#import "ACRTextBlockCitationParser.h"
#import "ACRInlineCitationTokenParser.h"
#import "ACRRichTextBlockCitationParser.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetConfiguration.h"
#import "ACOReference.h"
#import "ACOCitation.h"
#import "ACRCitationParserDelegate.h"
#import "ACRView.h"
#import "ACRCitationReferenceView.h"
#import "ACRCitationReferenceMoreDetailsView.h"
#import "ACRRenderer.h"
#import "ACRRenderResult.h"

@interface ACRCitationManager () <ACRCitationParserDelegate, ACRCitationReferenceViewDelegate>

@property (nonatomic, weak) id<ACRCitationManagerDelegate> delegate;
@property (nonatomic, weak) UIViewController *citationMainBottomSheet;

// Lazy properties
@property (nonatomic, strong) ACRTextBlockCitationParser *textBlockParser;
@property (nonatomic, strong) ACRInlineCitationTokenParser *inlineCitationParser;
@property (nonatomic, strong) ACRRichTextBlockCitationParser *citationRunParser;
@property (nonatomic, weak) UIViewController *activeViewController;

@end

@implementation ACRCitationManager

- (instancetype)initWithDelegate:(id<ACRCitationManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Lazy Properties

- (ACRTextBlockCitationParser *)textBlockParser {
    if (!_textBlockParser) {
        _textBlockParser = [[ACRTextBlockCitationParser alloc] initWithDelegate:self];
    }
    return _textBlockParser;
}

- (ACRInlineCitationTokenParser *)inlineCitationParser {
    if (!_inlineCitationParser) {
        _inlineCitationParser = [[ACRInlineCitationTokenParser alloc] initWithDelegate:self];
    }
    return _inlineCitationParser;
}

- (ACRRichTextBlockCitationParser *)citationRunParser {
    if (!_citationRunParser) {
        _citationRunParser = [[ACRRichTextBlockCitationParser alloc] initWithDelegate:self];
    }
    return _citationRunParser;
}

#pragma mark - Public Methods

- (NSAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString
                                                references:(NSArray<ACOReference *> *)references
{
    // Use inline citation parser for token-based citation parsing
    NSMutableAttributedString *result = [self.inlineCitationParser parseAttributedString:attributedString
                                                                          withReferences:references
                                                                                   theme:self.rootView.theme];
    return [result copy];
}

- (NSAttributedString *)buildCitationsFromNSLinkAttributesInAttributedString:(NSAttributedString *)attributedString
                                                                  references:(NSArray<ACOReference *> *)references
{
    // Use TextBlock parser for NSLink-based citation parsing from attributed strings
    NSMutableAttributedString *result = [self.textBlockParser parseAttributedString:attributedString
                                                                     withReferences:references
                                                                              theme:self.rootView.theme];
    return [result copy];
}

- (NSAttributedString *)buildCitationAttachmentWithCitation:(ACOCitation *)citation
                                                 references:(NSArray<ACOReference *> *)references {
    // Use CitationRun parser to create citation attributed string
    return [self.citationRunParser parseAttributedStringWithCitation:citation
                                                       andReferences:references];
}

#pragma mark - ACRCitationParserDelegate

- (void)citationParser:(id)parser
        didTapCitation:(ACOCitation *)citation
         referenceData:(ACOReference * _Nullable)referenceData {
    
    // Handle citation tap from parser - delegate to the main delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(citationManager:didTapCitation:referenceData:)]) {
        [self.delegate citationManager:self didTapCitation:citation referenceData:referenceData];
    }
    
    // Show bottom sheet
    id<ACRActionDelegate> actionDelegate = self.rootView.acrActionDelegate;
    
    if (![actionDelegate respondsToSelector:@selector(activeViewController)])
    {
        return;
    }
    
    UIViewController *host = [actionDelegate activeViewController];
    [self presentBottomSheetFrom:host didTapCitation:citation referenceData:referenceData];
    
}

- (void)presentBottomSheetFrom:(UIViewController *)activeController didTapCitation:(ACOCitation *)citation  referenceData:(ACOReference * _Nullable)referenceData {
    
    self.activeViewController = activeController;
    ACRCitationReferenceView *citationView = [[ACRCitationReferenceView alloc] initWithCitation:citation
                                                                                       reference:referenceData];
    citationView.delegate = self;

    ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc] initWithHostConfig:self.rootView.hostConfig];
    config.dismissButtonType = ACRBottomSheetDismissButtonTypeDragIndicator;
    config.contentPadding = 0;
    
    ACRBottomSheetViewController *currentBottomSheet = [[ACRBottomSheetViewController alloc] initWithContent:citationView
                                                                                               configuration:config];
    self.citationMainBottomSheet = currentBottomSheet;
    [activeController presentViewController:currentBottomSheet animated:YES completion:nil];
}

#pragma mark - ACRCitationReferenceViewDelegate

- (void)citationReferenceView:(ACRCitationReferenceView *)citationReferenceView
 didTapMoreDetailsForCitation:(ACOCitation *)citation
                    reference:(ACOReference *)reference
{
    ACRRenderResult *renderResult = [ACRRenderer render:reference.content
                                                 config:self.rootView.hostConfig
                                        widthConstraint:self.rootView.frame.size.width
                                                  theme:citation.theme];
    
    ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc] initWithHostConfig:self.rootView.hostConfig];
    config.minHeight = self.citationMainBottomSheet.preferredContentSize.height;
    config.dismissButtonType = ACRBottomSheetDismissButtonTypeDragIndicator;
    UIView *resultView = (UIView *)renderResult.view;
    ACRCitationReferenceMoreDetailsView *moreDetailsView = [[ACRCitationReferenceMoreDetailsView alloc] initWithAdaptiveCard: resultView];
    ACRBottomSheetViewController *currentBottomSheet = [[ACRBottomSheetViewController alloc] initWithContent:moreDetailsView
                                                                                               configuration:config];
    [self.citationMainBottomSheet presentViewController:currentBottomSheet animated:YES completion:nil];
}

@end
