//
//  ACRCitationReferenceView.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 31/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationReferenceView.h"
#import "ACOReference.h"
#import "ACOCitation.h"

@interface UIColor (ACRCitationReferenceView)
+ (UIColor *)grayColorWithValue:(NSInteger)value;
@end

@interface ACRCitationReferenceView ()

// Main structure - Root vertical stack view
@property (nonatomic, weak) UIStackView *rootStackView;

// Header section with title and separator
@property (nonatomic, weak) UIView *headerSection;
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UIView *separatorView;

// Main content horizontal stack view
@property (nonatomic, weak) UIStackView *mainContentStackView;

// Left side (pill + icon) horizontal stack view
@property (nonatomic, weak) UIStackView *leftSideStackView;
@property (nonatomic, weak) UIView *pillContainer;
@property (nonatomic, weak) UILabel *pillLabel;
@property (nonatomic, weak) UIImageView *iconImageView;

// Right side content vertical stack view
@property (nonatomic, weak) UIStackView *rightSideStackView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *abstractLabel;

// Keywords label
@property (nonatomic, weak) UILabel *keywordsLabel;

// More details button
@property (nonatomic, weak) UIButton *moreDetailsButton;

@end

@implementation ACRCitationReferenceView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCitation:(ACOCitation *)citation reference:(ACOReference *)reference {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self updateWithCitation:citation reference:reference];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    // Create root vertical stack view with padding
    UIStackView *rootStackView = [[UIStackView alloc] init];
    rootStackView.axis = UILayoutConstraintAxisVertical;
    rootStackView.spacing = 8;
    rootStackView.alignment = UIStackViewAlignmentFill;
    rootStackView.translatesAutoresizingMaskIntoConstraints = NO;


    [self addSubview:rootStackView];
    self.rootStackView = rootStackView;
    
    // Setup header section (title only, no separator)
    UIView *headerSection = [self setupHeaderSection];
    [self.rootStackView addArrangedSubview:headerSection];
    self.headerSection = headerSection;

    
    // Add separator as direct child of main view (spans full width)
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor grayColorWithValue:224];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    self.separatorView = separatorView;
    
    // Setup main content section
    UIStackView *mainContentStackView = [self setupMainContentSection];
    [self.rootStackView addArrangedSubview:mainContentStackView];
    self.mainContentStackView = mainContentStackView;
    
    // Setup constraints
    [self setupConstraints];
}

// Header section with "References" title only
- (UIView *) setupHeaderSection {
    UIView *headerSection = [[UIView alloc] init];
    headerSection.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Header title label
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.text = @"References";
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    headerTitleLabel.textColor =  [UIColor grayColorWithValue:32];
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;


    [headerSection addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;

    return headerSection;
}

// Main content horizontal stack view
- (UIStackView *)setupMainContentSection {
    UIStackView *mainContentStackView = [[UIStackView alloc] init];
    mainContentStackView.axis = UILayoutConstraintAxisHorizontal;
    mainContentStackView.spacing = 8;
    mainContentStackView.alignment = UIStackViewAlignmentTop;
    mainContentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Setup left side (pill + icon)
    UIStackView *leftSideStackView = [self setupLeftSideSection];
    [mainContentStackView addArrangedSubview:leftSideStackView];
    self.leftSideStackView = leftSideStackView;
    
    // Setup right side content
    UIStackView *rightSideStackView = [self setupRightSideSection];
    [mainContentStackView addArrangedSubview:rightSideStackView];
    self.rightSideStackView = rightSideStackView;
    
    return mainContentStackView;
}

// Left side horizontal stack view (pill + icon)
- (UIStackView *)setupLeftSideSection {
    UIStackView *leftSideStackView = [[UIStackView alloc] init];
    leftSideStackView.axis = UILayoutConstraintAxisHorizontal;
    leftSideStackView.spacing = 8;
    leftSideStackView.alignment = UIStackViewAlignmentTop;
    
    // Pill label with border and padding
    UILabel *pillLabel = [[UILabel alloc] init];
    pillLabel.textAlignment = NSTextAlignmentCenter;
    pillLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    pillLabel.textColor = [UIColor labelColor];
    pillLabel.numberOfLines = 0;
    pillLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Create a container view for the pill label to handle padding
    UIView *pillContainer = [[UIView alloc] init];
    pillContainer.translatesAutoresizingMaskIntoConstraints = NO;
    pillContainer.layer.borderColor = [UIColor separatorColor].CGColor;
    pillContainer.layer.borderWidth = 1.0;
    pillContainer.layer.cornerRadius = 4;
    pillContainer.layer.masksToBounds = YES;

    [pillContainer addSubview:pillLabel];
    
    [leftSideStackView addArrangedSubview:pillContainer];
    self.pillContainer = pillContainer;
    self.pillLabel = pillLabel;
    
    // Icon image view
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [leftSideStackView addArrangedSubview:iconImageView];
    self.iconImageView = iconImageView;
    
    return leftSideStackView;
}

// Right side vertical stack view (title, keywords, abstract)
- (UIStackView *)setupRightSideSection {
    UIStackView *rightSideStackView = [[UIStackView alloc] init];
    rightSideStackView.axis = UILayoutConstraintAxisVertical;
    rightSideStackView.spacing = 8;
    rightSideStackView.alignment = UIStackViewAlignmentLeading;
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.numberOfLines = 0;
    [rightSideStackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // Keywords label
    UILabel *keywordsLabel = [self setupKeywordsSection];
    [rightSideStackView addArrangedSubview:keywordsLabel];
    self.keywordsLabel = keywordsLabel;
    
    // Abstract label
    UILabel *abstractLabel = [[UILabel alloc] init];
    abstractLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    abstractLabel.textColor = [UIColor grayColorWithValue:34];
    abstractLabel.numberOfLines = 0;
    [rightSideStackView addArrangedSubview:abstractLabel];
    self.abstractLabel = abstractLabel;
    
    // More details button
    UIButton *moreDetailsButton = [self setupMoreDetailsButton];
    [rightSideStackView addArrangedSubview:moreDetailsButton];
    self.moreDetailsButton = moreDetailsButton;
    
    // Set content priorities
    [titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [abstractLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    return rightSideStackView;
}

// Keywords label with attributed string
- (UILabel *)setupKeywordsSection {
    UILabel *keywordsLabel = [[UILabel alloc] init];
    keywordsLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    keywordsLabel.textColor = [UIColor grayColorWithValue:110];
    keywordsLabel.numberOfLines = 0;
    return keywordsLabel;
}

// More details button setup
- (UIButton *)setupMoreDetailsButton {
    UIButton *moreDetailsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    // Create attributed string with "More details" text and chevron
    NSMutableAttributedString *buttonText = [[NSMutableAttributedString alloc] init];
    
    // "More details" text
    NSAttributedString *detailsText = [[NSAttributedString alloc] initWithString:@"More details" 
                                                                      attributes:@{
        NSForegroundColorAttributeName: [UIColor systemBlueColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]
    }];
    [buttonText appendAttributedString:detailsText];
    
    // Chevron symbol
    NSAttributedString *chevron = [[NSAttributedString alloc] initWithString:@" >" 
                                                                  attributes:@{
        NSForegroundColorAttributeName: [UIColor systemBlueColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]
    }];
    [buttonText appendAttributedString:chevron];
    
    [moreDetailsButton setAttributedTitle:buttonText forState:UIControlStateNormal];
    moreDetailsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    moreDetailsButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add target for button tap
    [moreDetailsButton addTarget:self 
                          action:@selector(moreDetailsButtonTapped:) 
                forControlEvents:UIControlEventTouchUpInside];
    
    return moreDetailsButton;
}

- (void)setupConstraints {
    // Root stack view constraints with 8pt padding
    [NSLayoutConstraint activateConstraints:@[
        [self.rootStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [self.rootStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [self.rootStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
        [self.rootStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8]
    ]];
    
    // Full-width separator positioned below header section
    [NSLayoutConstraint activateConstraints:@[
        [self.separatorView.topAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor],
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:1]
    ]];
    
    // Header section constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.headerSection.heightAnchor constraintEqualToConstant:40],
        [self.headerTitleLabel.heightAnchor constraintEqualToConstant:28],
        [self.headerTitleLabel.topAnchor constraintEqualToAnchor:self.headerSection.topAnchor],
        [self.headerTitleLabel.leadingAnchor constraintEqualToAnchor:self.headerSection.leadingAnchor],
        [self.headerTitleLabel.trailingAnchor constraintEqualToAnchor:self.headerSection.trailingAnchor],
        [self.headerTitleLabel.bottomAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor constant:-12]
    ]];

    // Left side stack view width constraint
    [NSLayoutConstraint activateConstraints:@[
        [self.leftSideStackView.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor multiplier:0.5]
    ]];
    
    // Add padding constraints - 1px on left and right
    [NSLayoutConstraint activateConstraints:@[
        [self.pillContainer.widthAnchor constraintGreaterThanOrEqualToConstant:17],
        [self.pillContainer.heightAnchor constraintGreaterThanOrEqualToConstant:17],
        [self.pillContainer.widthAnchor constraintLessThanOrEqualToConstant:50], /*Enough room for 5 characters*/
        [self.pillLabel.topAnchor constraintEqualToAnchor:self.pillContainer.topAnchor constant:1],
        [self.pillLabel.bottomAnchor constraintEqualToAnchor:self.pillContainer.bottomAnchor constant:-1],
        [self.pillLabel.leadingAnchor constraintEqualToAnchor:self.pillContainer.leadingAnchor constant:2.0],
        [self.pillLabel.trailingAnchor constraintEqualToAnchor:self.pillContainer.trailingAnchor constant:-2.0],
    ]];
    
    [self.pillLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    // Icon image view constraints - 32x32 with 1:1 aspect ratio
    [NSLayoutConstraint activateConstraints:@[
        [self.iconImageView.widthAnchor constraintEqualToConstant:32],
        [self.iconImageView.heightAnchor constraintEqualToConstant:32],
        [self.iconImageView.widthAnchor constraintEqualToAnchor:self.iconImageView.heightAnchor]
    ]];
    
    // Keywords label minimum height constraint
    [NSLayoutConstraint activateConstraints:@[
        [self.keywordsLabel.heightAnchor constraintGreaterThanOrEqualToConstant:16]
    ]];
}

#pragma mark - Button Actions

- (void)moreDetailsButtonTapped:(UIButton *)sender {
    // Notify delegate about the more details button tap
    if (self.delegate && [self.delegate respondsToSelector:@selector(citationReferenceView:didTapMoreDetailsForCitation:reference:)]) {
        [self.delegate citationReferenceView:self 
                  didTapMoreDetailsForCitation:self.citation 
                                     reference:self.reference];
    }
}

#pragma mark - Public Methods

- (void)updateWithCitation:(ACOCitation *)citation reference:(ACOReference *)reference {
    self.citation = citation;
    self.reference = reference;
    
    // Update pill label with citation display text
    self.pillLabel.text = citation.displayText ?: @"";
    
    // Update title
    self.titleLabel.text = reference.title ?: @"Unknown Reference";
    
    // Update keywords with separators
    [self updateKeywordsDisplay:reference.keywords];
    
    // Update abstract
    if (reference.abstract && reference.abstract.length > 0) {
        self.abstractLabel.text = reference.abstract;
        self.abstractLabel.hidden = NO;
    } else {
        self.abstractLabel.hidden = YES;
    }
    
    // Update icon
    [self updateIconForReference:reference];
    
    // Show/hide more details button based on URL availability or content availability
    self.moreDetailsButton.hidden = reference.content == nil;
}

- (void)updateKeywordsDisplay:(NSArray<NSString *> *)keywords {
    if (keywords && keywords.count > 0) {
        // Limit to max 3 keywords as per spec
        NSInteger maxKeywords = MIN(keywords.count, 3);
        NSArray *displayKeywords = [keywords subarrayWithRange:NSMakeRange(0, maxKeywords)];
        
        // Create attributed string with keywords separated by "|"
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        for (NSInteger i = 0; i < displayKeywords.count; i++) {
            // Add separator if not first keyword
            if (i > 0) {
                NSAttributedString *separator = [[NSAttributedString alloc] initWithString:@" | " 
                                                                                 attributes:@{
                    NSForegroundColorAttributeName: [UIColor tertiaryLabelColor],
                    NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]
                }];
                [attributedString appendAttributedString:separator];
            }
            
            // Add keyword
            NSAttributedString *keyword = [[NSAttributedString alloc] initWithString:displayKeywords[i]
                                                                          attributes:@{
                NSForegroundColorAttributeName: [UIColor secondaryLabelColor],
                NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]
            }];
            [attributedString appendAttributedString:keyword];
        }
        
        self.keywordsLabel.attributedText = attributedString;
        self.keywordsLabel.hidden = NO;
    } else {
        self.keywordsLabel.attributedText = nil;
        self.keywordsLabel.hidden = YES;
    }
}

- (void)updateIconForReference:(ACOReference *)reference {
    // Set default document icon
    UIImage *iconImage = [UIImage systemImageNamed:@"doc.fill"];
    
    // Customize icon based on reference type or URL
    if (reference.url) {
        NSString *urlString = reference.url.lowercaseString;
        
        if ([urlString containsString:@".pdf"]) {
            iconImage = [UIImage systemImageNamed:@"doc.fill"];
            self.iconImageView.tintColor = [UIColor systemRedColor];
        } else if ([urlString containsString:@".doc"] || [urlString containsString:@".docx"]) {
            iconImage = [UIImage systemImageNamed:@"doc.fill"];
            self.iconImageView.tintColor = [UIColor systemBlueColor];
        } else if ([urlString containsString:@".ppt"] || [urlString containsString:@".pptx"]) {
            iconImage = [UIImage systemImageNamed:@"doc.fill"];
            self.iconImageView.tintColor = [UIColor systemOrangeColor];
        } else {
            iconImage = [UIImage systemImageNamed:@"link"];
            self.iconImageView.tintColor = [UIColor systemBlueColor];
        }
    } else {
        self.iconImageView.tintColor = [UIColor systemGrayColor];
    }
    
    self.iconImageView.image = iconImage;
}
@end

#pragma mark - UIColor Private Extension

@implementation UIColor (ACRCitationReferenceView)

+ (UIColor *)grayColorWithValue:(NSInteger)value {
    // Clamp value to 0-255 range
    NSInteger clampedValue = MAX(0, MIN(255, value));
    CGFloat normalizedValue = clampedValue / 255.0;
    
    return [UIColor colorWithRed:normalizedValue 
                           green:normalizedValue 
                            blue:normalizedValue 
                           alpha:1.0];
}

@end
