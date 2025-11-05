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

@interface ACRCitationManager () <ACRCitationParserDelegate, ACRCitationReferenceViewDelegate>

@property (nonatomic, weak) id<ACRCitationManagerDelegate> delegate;

// Lazy properties
@property (nonatomic, strong) ACRTextBlockCitationParser *textBlockParser;
@property (nonatomic, strong) ACRInlineCitationTokenParser *inlineCitationParser;
@property (nonatomic, strong) ACRRichTextBlockCitationParser *citationRunParser;
@property (nonatomic, strong) ACRBottomSheetViewController *bottomSheetPopover;
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
                                                     theme:(ACRTheme) theme
{
    // Use inline citation parser for token-based citation parsing
    NSMutableAttributedString *result = [self.inlineCitationParser parseAttributedString:attributedString
                                                                          withReferences:references
                                                                                   theme:theme];
    return [result copy];
}

- (NSAttributedString *)buildCitationsFromNSLinkAttributesInAttributedString:(NSAttributedString *)attributedString
                                                                  references:(NSArray<ACOReference *> *)references
                                                                       theme:(ACRTheme) theme
{
    // Use TextBlock parser for NSLink-based citation parsing from attributed strings
    NSMutableAttributedString *result = [self.textBlockParser parseAttributedString:attributedString
                                                                     withReferences:references
                                                                              theme:theme];
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
    config.showCloseButton = NO;
    config.contentPadding = 0;
    
    self.bottomSheetPopover = [[ACRBottomSheetViewController alloc] initWithContent:citationView configuration:config];

    [activeController presentViewController:self.bottomSheetPopover animated:YES completion:nil];
}

#pragma mark - ACRCitationReferenceViewDelegate

- (void)citationReferenceView:(ACRCitationReferenceView *)citationReferenceView 
         didTapMoreDetailsForCitation:(ACOCitation *)citation 
                            reference:(ACOReference *)reference {
    
    [self.bottomSheetPopover dismissViewControllerAnimated:NO completion:nil];
        
    ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc] initWithHostConfig:self.rootView.hostConfig];
    config.minHeight = self.bottomSheetPopover.preferredContentSize.height;
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    v.backgroundColor = UIColor.redColor;

    ACRBottomSheetViewController *popover = [[ACRBottomSheetViewController alloc] initWithContent:v configuration:config];
    
        __weak ACRCitationManager *weakSelf = self;
    popover.onDismissBlock = ^{
        if (weakSelf)
        {
            [weakSelf.activeViewController presentViewController:weakSelf.bottomSheetPopover animated:YES completion:nil];
        }
    };

    [self.activeViewController presentViewController:popover animated:YES completion:nil];
   
}

@end
