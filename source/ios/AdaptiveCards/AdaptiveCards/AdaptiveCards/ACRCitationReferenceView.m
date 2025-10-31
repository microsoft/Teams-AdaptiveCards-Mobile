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

// Main structure - A (Root vertical stack view)
@property (nonatomic, weak) UIStackView *rootStackView; // A

// A1 - Header section with title and separator
@property (nonatomic, weak) UIView *headerSection; // A1
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UIView *separatorView;

// B - Main content horizontal stack view
@property (nonatomic, weak) UIStackView *mainContentStackView; // B

// C - Left side (pill + icon) horizontal stack view
@property (nonatomic, weak) UIStackView *leftSideStackView; // C
@property (nonatomic, weak) UILabel *pillLabel; // C1
@property (nonatomic, weak) UIImageView *iconImageView; // C2

// D - Right side content vertical stack view
@property (nonatomic, weak) UIStackView *rightSideStackView; // D
@property (nonatomic, weak) UILabel *titleLabel; // D1
@property (nonatomic, weak) UILabel *abstractLabel; // D2

// E - Keywords label (inside D)
@property (nonatomic, weak) UILabel *keywordsLabel; // E

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
    
    // A - Create root vertical stack view with padding
    UIStackView *rootStackView = [[UIStackView alloc] init];
    rootStackView.axis = UILayoutConstraintAxisVertical;
    rootStackView.spacing = 8;
    rootStackView.alignment = UIStackViewAlignmentFill;
    rootStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:rootStackView];
    self.rootStackView = rootStackView;
    
    // Setup A1 - Header section (title only, no separator)
    UIView *headerSection = [self setupHeaderSection];
    [self.rootStackView addArrangedSubview:headerSection];
    self.headerSection = headerSection;
    
    // Add separator as direct child of main view (spans full width)
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor grayColorWithValue:224];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    self.separatorView = separatorView;
    
    // Setup B - Main content section
    UIStackView *mainContentStackView = [self setupMainContentSection];
    [self.rootStackView addArrangedSubview:mainContentStackView];
    self.mainContentStackView = mainContentStackView;
    
    // Setup constraints
    [self setupConstraints];
}

// A1 - Header section with "References" title only
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
    
    // Header section constraints - only title label
    [NSLayoutConstraint activateConstraints:@[
        [headerTitleLabel.topAnchor constraintEqualToAnchor:headerSection.topAnchor],
        [headerTitleLabel.leadingAnchor constraintEqualToAnchor:headerSection.leadingAnchor],
        [headerTitleLabel.trailingAnchor constraintEqualToAnchor:headerSection.trailingAnchor],
        [headerTitleLabel.bottomAnchor constraintEqualToAnchor:headerSection.bottomAnchor]
    ]];
    return headerSection;
}

// B - Main content horizontal stack view
- (UIStackView *)setupMainContentSection {
    UIStackView *mainContentStackView = [[UIStackView alloc] init];
    mainContentStackView.axis = UILayoutConstraintAxisHorizontal;
    mainContentStackView.spacing = 16;
    mainContentStackView.alignment = UIStackViewAlignmentTop;
    mainContentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    mainContentStackView.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.1]; // B - Main content
    
    // Setup C - Left side (pill + icon)
    UIStackView *leftSideStackView = [self setupLeftSideSection];
    [mainContentStackView addArrangedSubview:leftSideStackView];
    self.leftSideStackView = leftSideStackView;
    
    // Setup D - Right side content
    UIStackView *rightSideStackView = [self setupRightSideSection];
    [mainContentStackView addArrangedSubview:rightSideStackView];
    self.rightSideStackView = rightSideStackView;
    
    return mainContentStackView;
}

// C - Left side horizontal stack view (pill + icon)
- (UIStackView *)setupLeftSideSection {
    UIStackView *leftSideStackView = [[UIStackView alloc] init];
    leftSideStackView.axis = UILayoutConstraintAxisHorizontal;
    leftSideStackView.spacing = 12;
    leftSideStackView.alignment = UIStackViewAlignmentCenter;
    leftSideStackView.backgroundColor = [[UIColor systemOrangeColor] colorWithAlphaComponent:0.1]; // C - Left side
    
    // C1 - Pill label with border
    UILabel *pillLabel = [[UILabel alloc] init];
    pillLabel.textAlignment = NSTextAlignmentCenter;
    pillLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    pillLabel.textColor = [UIColor labelColor];
    pillLabel.backgroundColor = [UIColor clearColor];
    pillLabel.layer.borderColor = [UIColor separatorColor].CGColor;
    pillLabel.layer.borderWidth = 1.0;
    pillLabel.layer.cornerRadius = 4;
    pillLabel.layer.masksToBounds = YES;
    pillLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [leftSideStackView addArrangedSubview:pillLabel];
    self.pillLabel = pillLabel;
    
    // C2 - Icon image view
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [leftSideStackView addArrangedSubview:iconImageView];
    self.iconImageView = iconImageView;
    
    return leftSideStackView;
}

// D - Right side vertical stack view (title, keywords, abstract)
- (UIStackView *)setupRightSideSection {
    UIStackView *rightSideStackView = [[UIStackView alloc] init];
    rightSideStackView.axis = UILayoutConstraintAxisVertical;
    rightSideStackView.spacing = 8;
    rightSideStackView.alignment = UIStackViewAlignmentLeading;
    rightSideStackView.backgroundColor = [[UIColor systemYellowColor] colorWithAlphaComponent:0.1]; // D - Right side
    
    // D1 - Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.numberOfLines = 0;
    [rightSideStackView addArrangedSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // E - Keywords label
    UILabel *keywordsLabel = [self setupKeywordsSection];
    [rightSideStackView addArrangedSubview:keywordsLabel];
    self.keywordsLabel = keywordsLabel;
    
    // D2 - Abstract label
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

// E - Keywords label with attributed string
- (UILabel *)setupKeywordsSection {
    UILabel *keywordsLabel = [[UILabel alloc] init];
    keywordsLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    keywordsLabel.textColor = [UIColor grayColorWithValue:110];
    keywordsLabel.numberOfLines = 0;
    keywordsLabel.backgroundColor = [[UIColor systemPinkColor] colorWithAlphaComponent:0.1]; // E - Keywords label
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
        [self.separatorView.topAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor constant:4],
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:1]
    ]];
    
    // Header height
    [NSLayoutConstraint activateConstraints:@[
        [self.headerSection.heightAnchor constraintEqualToConstant:36]
    ]];
    
    // Left side stack view width constraint
    [NSLayoutConstraint activateConstraints:@[
        [self.leftSideStackView.widthAnchor constraintEqualToConstant:80]
    ]];
    
    // Pill label constraints - rectangular with padding
    [NSLayoutConstraint activateConstraints:@[
        [self.pillLabel.widthAnchor constraintGreaterThanOrEqualToConstant:32],
        [self.pillLabel.heightAnchor constraintEqualToConstant:24]
    ]];
    
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
    // Handle more details button tap
    // This can be extended to call a delegate method or open a URL
    if (self.reference.url && self.reference.url.length > 0) {
        NSURL *url = [NSURL URLWithString:self.reference.url];
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

#pragma mark - Public Methods

- (void)updateWithCitation:(ACOCitation *)citation reference:(ACOReference *)reference {
    self.citation = citation;
    self.reference = reference;
    
    // Update pill label with citation display text
    self.pillLabel.text = citation.displayText ?: @"?";
    
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
    
    // Show/hide more details button based on URL availability
    if (reference.url && reference.url.length > 0) {
        self.moreDetailsButton.hidden = NO;
    } else {
        self.moreDetailsButton.hidden = YES;
    }
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

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return [self.rootStackView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Pill has fixed corner radius for rectangular shape
    self.pillLabel.layer.cornerRadius = 4;
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
