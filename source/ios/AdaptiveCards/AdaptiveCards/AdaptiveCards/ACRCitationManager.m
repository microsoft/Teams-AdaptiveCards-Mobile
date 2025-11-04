//
//  ACRCitationManager.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationManager.h"
#import "ACRInlineCitationTokenParser.h"
#import "ACRRichTextBlockCitationParser.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetConfiguration.h"
#import "ACOReference.h"
#import "ACOCitation.h"

@interface ACRCitationManager () <ACRCitationParserDelegate>

@property (nonatomic, weak) id<ACRCitationManagerDelegate> delegate;

// Lazy properties
@property (nonatomic, strong) ACRInlineCitationTokenParser *inlineCitationParser;
@property (nonatomic, strong) ACRRichTextBlockCitationParser *citationRunParser;

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

- (NSMutableAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString 
                                                       references:(NSArray<ACOReference *> *)references {
    // Use TextBlock parser for regex-based citation parsing
    return [self.inlineCitationParser parseAttributedString:attributedString withReferences:references];
}

#pragma mark - ACRCitationParserDelegate

- (void)citationParser:(id)parser 
        didTapCitation:(ACOCitation *)citation 
         referenceData:(ACOReference * _Nullable)referenceData {
    
    // Handle citation tap from parser - delegate to the main delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(citationManager:didTapCitation:referenceData:)]) {
        [self.delegate citationManager:self didTapCitation:citation referenceData:referenceData];
    }
    
    // TODO: Show BottomSheet
    // TEMP: Show an alert as a placeholder for bottom sheet
    if ([self.delegate respondsToSelector:@selector(parentViewControllerForCitationPresentation)]) {
        UIViewController *parentViewController = [self.delegate parentViewControllerForCitationPresentation];
        if (parentViewController) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Citation Tapped"
                                                                                     message:@"A citation was tapped. Handle accordingly."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                                               style:UIAlertActionStyleDefault 
                                                             handler:nil];
            [alertController addAction:okAction];
            [parentViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

@end
