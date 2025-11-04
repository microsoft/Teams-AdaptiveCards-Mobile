//
//  ACRCitationManager.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationManager.h"
#import "ACRTextBlockCitationParser.h"
#import "ACRRichTextBlockCitationParser.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetConfiguration.h"
#import "ACOReference.h"

@interface ACRCitationManager () <ACRCitationParserDelegate>

@property (nonatomic, weak) id<ACRCitationManagerDelegate> delegate;

// Lazy properties
@property (nonatomic, strong) ACRTextBlockCitationParser *textBlockParser;
@property (nonatomic, strong) ACRRichTextBlockCitationParser *richTextBlockParser;

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

- (ACRRichTextBlockCitationParser *)richTextBlockParser {
    if (!_richTextBlockParser) {
        _richTextBlockParser = [[ACRRichTextBlockCitationParser alloc] initWithDelegate:self];
    }
    return _richTextBlockParser;
}

#pragma mark - Public Methods

- (NSMutableAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString 
                                                       references:(NSArray<ACOReference *> *)references {
    // Use TextBlock parser for regex-based citation parsing
    return [self.textBlockParser parseAttributedString:attributedString withReferences:references];
}

#pragma mark - ACRCitationParserDelegate

- (void)citationParser:(id)parser 
      didTapCitationWithData:(NSDictionary *)citationData 
               referenceData:(ACOReference * _Nullable)referenceData {
    
    // Handle citation tap from parser - delegate to the main delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(citationManager:didTapCitationWithData:referenceData:)]) {
        [self.delegate citationManager:self didTapCitationWithData:citationData referenceData:referenceData];
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
