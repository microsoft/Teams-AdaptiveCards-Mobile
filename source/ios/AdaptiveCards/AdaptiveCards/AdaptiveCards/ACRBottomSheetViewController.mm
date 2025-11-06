//
//  ACRBottomSheetViewController.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOHostConfigPrivate.h"
#import "ACRSVGImageView.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetPresentationController.h"
#import "ACRBottomSheetConfiguration.h"
#import "UtiliOS.h"

@interface ACRBottomSheetViewController ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIButton *dismissButton;
@property (nonatomic, weak) UIView *dragIndicator;
@property (nonatomic, weak) UIView *headerSection;
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UIView *separatorView;
@property (nonatomic) UIView *contentView;
@property (nonatomic) ACRBottomSheetConfiguration *config;

@end

@implementation ACRBottomSheetViewController

- (instancetype)initWithContent:(UIView *)content
                  configuration:(ACRBottomSheetConfiguration *)config;

{
    if (self = [super init])
    {
        _contentView = content;
        _config = config;
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate  = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [self.config.hostConfig getPopoverBackgroundColor];
    
    // Setup header if headerText is provided
    if (self.config.headerText && self.config.headerText.length > 0) {
        [self setupHeaderSection];
    }
    
    switch (self.config.dismissButtonType) {
        case ACRBottomSheetDismissButtonTypeCross:
            [self setupDismissButton: @"Dismiss"];
            break;
        case ACRBottomSheetDismissButtonTypeDragIndicator:
            [self setupDragIndicator];
            break;
        case ACRBottomSheetDismissButtonTypeBack:
            [self setupDismissButton: @"ChevronLeft"];
            break;
        default:
            // No dismiss UI
            break;
    }
    
    [self setupScrollView];
    [self setupConstraints];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.onDismissBlock)
    {
        self.onDismissBlock();
    }
}

- (void)setupDismissButton:(NSString *)buttonIconName
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.accessibilityLabel = NSLocalizedString(buttonIconName, nil);
    NSString *dismissIcon = buttonIconName.lowercaseString;
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@/%@.json", baseFluentIconCDNURL, dismissIcon, dismissIcon];
    CGSize iconSize = CGSizeMake(24, 24);
    UIColor *tintColor = [self.config.hostConfig getPopoverTintColor];
    UIImageView *imageView = [[ACRSVGImageView alloc] init:url
                                                       rtl:ACRRtlNone
                                                  isFilled:false
                                                      size:iconSize
                                                 tintColor:tintColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [dismissButton addSubview:imageView];
    [dismissButton addTarget:self
                      action:@selector(closeAction)
            forControlEvents:UIControlEventTouchUpInside];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dismissButton];
    self.dismissButton = dismissButton;
}

- (void)setupDragIndicator
{
    UIView *dragIndicator = [[UIView alloc] init];
    dragIndicator.backgroundColor = [UIColor tertiaryLabelColor];
    dragIndicator.layer.cornerRadius = 2.0;
    dragIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dragIndicator];
    self.dragIndicator = dragIndicator;
}

- (void)setupHeaderSection
{
    // Header Constants
    static const CGFloat kACRCitationHeaderHeight = 40.0;
    static const CGFloat kACRCitationHeaderTitleHeight = 28.0;
    static const CGFloat kACRCitationHeaderBottomPadding = 12.0;
    static const CGFloat kACRCitationHeaderFontSize = 17.0;
    static const NSInteger kACRCitationHeaderTextColor = 32;
    static const CGFloat kACRCitationSeparatorHeight = 1.0;
    static const NSInteger kACRCitationSeparatorColor = 224;
    
    // Header section
    UIView *headerSection = [[UIView alloc] init];
    headerSection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerSection];
    self.headerSection = headerSection;
    
    // Header title label
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.text = self.config.headerText;
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.font = [UIFont systemFontOfSize:kACRCitationHeaderFontSize weight:UIFontWeightSemibold];
    
    // Gray color helper
    NSInteger clampedValue = MAX(0, MIN(255, kACRCitationHeaderTextColor));
    CGFloat normalizedValue = clampedValue / 255.0;
    UIColor *grayColor = [UIColor colorWithRed:normalizedValue green:normalizedValue blue:normalizedValue alpha:1.0];
    headerTitleLabel.textColor = grayColor;
    
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerSection addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;
    
    // Separator
    UIView *separatorView = [[UIView alloc] init];
    NSInteger clampedSeparatorValue = MAX(0, MIN(255, kACRCitationSeparatorColor));
    CGFloat normalizedSeparatorValue = clampedSeparatorValue / 255.0;
    UIColor *separatorColor = [UIColor colorWithRed:normalizedSeparatorValue green:normalizedSeparatorValue blue:normalizedSeparatorValue alpha:1.0];
    separatorView.backgroundColor = separatorColor;
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:separatorView];
    self.separatorView = separatorView;
    
    // Header constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.headerSection.heightAnchor constraintEqualToConstant:kACRCitationHeaderHeight],
        [self.headerSection.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerSection.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        [self.headerTitleLabel.heightAnchor constraintEqualToConstant:kACRCitationHeaderTitleHeight],
        [self.headerTitleLabel.topAnchor constraintEqualToAnchor:self.headerSection.topAnchor],
        [self.headerTitleLabel.leadingAnchor constraintEqualToAnchor:self.headerSection.leadingAnchor],
        [self.headerTitleLabel.trailingAnchor constraintEqualToAnchor:self.headerSection.trailingAnchor],
        [self.headerTitleLabel.bottomAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor constant:-kACRCitationHeaderBottomPadding],
        
        [self.separatorView.topAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor],
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:kACRCitationSeparatorHeight]
    ]];
}

- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    [self.contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)setupConstraints
{
    CGFloat contentPad = self.config.contentPadding;
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
    
    // Determine the top anchor for scroll view based on header and dismiss button presence
    NSLayoutYAxisAnchor *scrollViewTopAnchor;
    CGFloat scrollViewTopConstant = 0;
    
    // If header exists, position header at top and scroll view below separator
    if (self.headerSection) {
        [constraints addObjectsFromArray:@[
            [self.headerSection.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:8]
        ]];
        scrollViewTopAnchor = self.separatorView.bottomAnchor;
        scrollViewTopConstant = 8;
    } else {
        // No header, position elements as before
        if (self.config.dismissButtonType == ACRBottomSheetDismissButtonTypeCross ||
            self.config.dismissButtonType == ACRBottomSheetDismissButtonTypeBack) {

            UIEdgeInsets btnInsets = self.config.closeButtonInsets;
            CGFloat closeBtnSize = self.config.closeButtonSize;

            // Dismiss button constraints (same for cross and back buttons)
            [constraints addObjectsFromArray:@[
                [self.dismissButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:btnInsets.top],
                [self.dismissButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:btnInsets.left],
                [self.dismissButton.widthAnchor constraintEqualToConstant:closeBtnSize],
                [self.dismissButton.heightAnchor constraintEqualToAnchor:self.dismissButton.widthAnchor],
            ]];
            
            scrollViewTopAnchor = self.view.topAnchor;
            scrollViewTopConstant = 20;
        } else if (self.config.dismissButtonType == ACRBottomSheetDismissButtonTypeDragIndicator) {
            // Drag indicator constraints
            [constraints addObjectsFromArray:@[
                [self.dragIndicator.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:8],
                [self.dragIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
                [self.dragIndicator.widthAnchor constraintEqualToConstant:36],
                [self.dragIndicator.heightAnchor constraintEqualToConstant:4],
            ]];
            
            scrollViewTopAnchor = self.view.topAnchor;
            scrollViewTopConstant = 20;
        } else {
            // No dismiss button - scroll view starts at top with padding
            scrollViewTopAnchor = self.view.topAnchor;
            scrollViewTopConstant = 8;
        }
    }
    
    // Scroll view top constraint
    [constraints addObject:[self.scrollView.topAnchor constraintEqualToAnchor:scrollViewTopAnchor constant:scrollViewTopConstant]];
    
    // Common scroll view and content constraints
    [constraints addObjectsFromArray:@[
        /* scroll container */
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        /* content inside scroll */
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:contentPad],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:(-contentPad)],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:(-2 * contentPad)],
    ]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (CGSize)preferredContentSize
{
    [self.view layoutIfNeeded];
    CGFloat header = CGRectGetMinY(self.scrollView.frame) + self.view.safeAreaInsets.bottom;
    CGFloat naturalHeight =  header + self.scrollView.contentSize.height;
    CGFloat presentingViewHeight = self.presentingViewController.view.bounds.size.height;
    CGFloat maxH = self.config.maxHeightMultiplier * presentingViewHeight;
    CGFloat min = self.config.minHeight;
    
    if (min == NSNotFound) {
        min = self.config.minHeightMultiplier * presentingViewHeight;
    }
    
    CGFloat sheetH = MAX(min, MIN(naturalHeight, maxH));
    self.scrollView.scrollEnabled = naturalHeight > sheetH;
    self.scrollView.alwaysBounceVertical = self.scrollView.scrollEnabled;
    return CGSizeMake(naturalHeight, sheetH);
}

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backAction
{
    // Check if we're in a navigation controller and can pop
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // Fallback to dismiss if not in navigation stack
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// MARK: Transition Delegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    ACRBottomSheetPresentationController *pres = [[ACRBottomSheetPresentationController alloc] initWithPresentedViewController:presented
                                                                presentingViewController:presenting];
    return pres;
}

@end
