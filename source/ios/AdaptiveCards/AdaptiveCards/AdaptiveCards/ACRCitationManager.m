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

@interface ACRCitationManager () <ACRCitationParserDelegate>
@property (nonatomic, weak) id<ACRCitationManagerDelegate> delegate;
@property (nonatomic, strong) ACRTextBlockCitationParser *textBlockParser;
@property (nonatomic, strong) ACRRichTextBlockCitationParser *richTextBlockParser;

@end

@implementation ACRCitationManager

- (instancetype)initWithDelegate:(id<ACRCitationManagerDelegate>)delegate {
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

- (NSMutableAttributedString *)parseAttributedString:(NSAttributedString *)attributedString 
                                      withReferences:(NSArray<NSDictionary *> *)references {
    // Use TextBlock parser for regex-based citation parsing
    return [self.textBlockParser parseAttributedString:attributedString withReferences:references];
}

- (NSMutableAttributedString *)parseAttributedStringWithCitations:(NSAttributedString *)attributedString 
                                                   withReferences:(NSArray<NSDictionary *> *)references {
    // Use RichTextBlock parser for embedded citation data parsing  
    return [self.richTextBlockParser parseAttributedString:attributedString withReferences:references];
}

#pragma mark - ACRCitationParserDelegate

- (void)citationParser:(id)parser 
      didTapCitationWithData:(NSDictionary *)citationData 
               referenceData:(NSDictionary * _Nullable)referenceData {
    // Handle citation tap from parser - delegate to the main delegate for presentation
    if (self.delegate && [self.delegate respondsToSelector:@selector(citationManager:didTapCitationWithData:referenceData:)]) {
        [self.delegate citationManager:self didTapCitationWithData:citationData referenceData:referenceData];
    }
    
    NSLog(@"Citation tapped - Citation: %@, Reference: %@", citationData, referenceData);
}



@end
