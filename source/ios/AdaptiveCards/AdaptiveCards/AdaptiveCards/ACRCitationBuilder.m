//
//  ACRCitationBuilder.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationBuilder.h"
#import "ACRTextBlockCitationParser.h"
#import "ACRInlineCitationTokenParser.h"
#import "ACRCitationParser.h"
#import "ACOReference.h"
#import "ACOCitation.h"
#import "ACRCitationParserDelegate.h"

@interface ACRCitationBuilder () <ACRCitationParserDelegate>

@property (nonatomic, weak) id<ACRCitationBuilderDelegate> delegate;
@property (nonatomic, weak) id<ACICitationPresenter> presenter;
@property (nonatomic, strong) ACRTextBlockCitationParser *textBlockParser;
@property (nonatomic, strong) ACRInlineCitationTokenParser *inlineCitationParser;
@property (nonatomic, strong) ACRCitationParser *citationRunParser;

@end

@implementation ACRCitationBuilder

- (instancetype)initWithDelegate:(id<ACRCitationBuilderDelegate>)delegate
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

- (ACRCitationParser *)citationRunParser {
    if (!_citationRunParser) {
        _citationRunParser = [[ACRCitationParser alloc] initWithDelegate:self];
    }
    return _citationRunParser;
}

#pragma mark - Public Methods

- (NSAttributedString *)buildCitationsFromAttributedString:(NSAttributedString *)attributedString
                                                references:(NSArray<ACOReference *> *)references
                                                 presenter:(id<ACICitationPresenter>)presenter
                                                     theme:(ACRTheme)theme
{
    self.presenter = presenter;
    NSMutableAttributedString *result = [self.inlineCitationParser parseAttributedString:attributedString
                                                                          withReferences:references
                                                                                   theme:theme];
    return [result copy];
}

- (NSAttributedString *)buildCitationsFromNSLinkAttributesInAttributedString:(NSAttributedString *)attributedString
                                                                  references:(NSArray<ACOReference *> *)references
                                                                   presenter:(id<ACICitationPresenter>)presenter
                                                                       theme:(ACRTheme)theme
{
    self.presenter = presenter;
    NSMutableAttributedString *result = [self.textBlockParser parseAttributedString:attributedString
                                                                     withReferences:references
                                                                              theme:theme];
    return [result copy];
}

- (NSAttributedString *)buildCitationAttachmentWithCitation:(ACOCitation *)citation
                                                 references:(NSArray<ACOReference *> *)references
                                                  presenter:(id<ACICitationPresenter>)presenter
{
    self.presenter = presenter;
    return [self.citationRunParser parseAttributedStringWithCitation:citation
                                                       andReferences:references];
}

#pragma mark - ACRCitationParserDelegate

- (void)citationParser:(id)parser
        didTapCitation:(ACOCitation *)citation
         referenceData:(ACOReference * _Nullable)referenceData {

    if (self.delegate && [self.delegate respondsToSelector:@selector(citationBuilder:didTapCitation:referenceData:)]) {
        [self.delegate citationBuilder:self didTapCitation:citation referenceData:referenceData];
    }

    if ([self.presenter respondsToSelector:@selector(handleCitationTap:referenceData:)]) {
        [self.presenter handleCitationTap:citation referenceData:referenceData];
    }
}

@end
