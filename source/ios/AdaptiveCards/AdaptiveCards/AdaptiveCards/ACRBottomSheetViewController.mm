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
@property (nonatomic, weak) UIView *contentView;
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
    self.view.backgroundColor = [_config.hostConfig getPopoverBackgroundColor];
    [self setupCloseButton];
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

- (void)setupCloseButton
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.accessibilityLabel = NSLocalizedString(@"Dismiss", nil);
    NSString *dismissIcon = @"dismiss";
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

- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
}

- (void)setupConstraints
{
    CGFloat contentPad = self.config.contentPadding;
    CGFloat btnTopInset = self.config.closeButtonTopInset;
    CGFloat btnSideInset = self.config.closeButtonSideInset;
    CGFloat scrollBtnGap = self.config.closeButtonToScrollGap;
    CGFloat closeBtnSize = self.config.closeButtonSize;
    
    [NSLayoutConstraint activateConstraints:@[
        
        /* Dismiss button constraints */
        [self.dismissButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:btnTopInset],
        [self.dismissButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:btnSideInset],
        [self.dismissButton.widthAnchor constraintEqualToConstant:closeBtnSize],
        [self.dismissButton.heightAnchor constraintEqualToAnchor:self.dismissButton.widthAnchor],
        
        /* scroll container */
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.topAnchor constraintEqualToAnchor:self.dismissButton.bottomAnchor constant:scrollBtnGap],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        /* content inside scroll */
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:contentPad],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:(-contentPad)],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:(-2 * contentPad)],
    ]];
}

- (CGSize)preferredContentSize
{
    [self.view layoutIfNeeded];
    CGFloat header  = CGRectGetMinY(self.scrollView.frame) + self.view.safeAreaInsets.bottom;
    CGFloat natural = header + self.scrollView.contentSize.height;
    CGFloat presentingViewHeight = self.presentingViewController.view.bounds.size.height;
    CGFloat minH = self.config.minHeightMultiplier * presentingViewHeight;
    CGFloat maxH = self.config.maxHeightMultiplier * presentingViewHeight;
    CGFloat sheetH = MAX(minH, MIN(natural, maxH));
    self.scrollView.scrollEnabled = natural > sheetH;
    self.scrollView.alwaysBounceVertical = self.scrollView.scrollEnabled;
    return CGSizeMake(natural, sheetH);
}

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: Transition Delegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[ACRBottomSheetPresentationController alloc] initWithPresentedViewController:presented
                                                                presentingViewController:presenting];
}

@end
