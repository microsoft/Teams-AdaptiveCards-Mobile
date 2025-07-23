//
//  ACRBottomSheetViewController.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRSVGImageView.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetPresentationController.h"
#import "ACRBottomSheetConfiguration.h"
#import "UtiliOS.h"

@interface ACRBottomSheetViewController ()
@property (nonatomic) UIScrollView *scroll;
@property (nonatomic) UIButton *closeBtn;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UIView *topBorder;
@property (nonatomic) ACRBottomSheetConfiguration *config;

@end


@implementation ACRBottomSheetViewController

- (instancetype)initWithContent:(UIView *)content
                  configuration:(ACRBottomSheetConfiguration *)config;

{
    if ((self = [super init])) {
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
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    [self setupCloseButton];
    [self setupScrollView];
    [self setupTopBorder];
    [self setupConstraints];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.onDismissBlock) {
        self.onDismissBlock();
    }
}

- (void)setupCloseButton
{
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *dismissIcon = @"dismiss";
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@/%@.json", baseFluentIconCDNURL, dismissIcon, dismissIcon];
    CGSize iconSize = CGSizeMake(24, 24);
    UIImageView *view = [[ACRSVGImageView alloc] init:url
                                                  rtl:ACRRtlNone
                                             isFilled:false
                                                 size:iconSize
                                            tintColor:self.closeBtn.currentTitleColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeBtn addSubview:view];
    [self.closeBtn addTarget:self
                      action:@selector(closeAction)
            forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.closeBtn];
}

- (void)setupScrollView
{
    self.scroll = [[UIScrollView alloc] init];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scroll];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scroll addSubview:self.contentView];
}

- (void)setupTopBorder
{
    self.topBorder = [[UIView alloc] init];
    self.topBorder.backgroundColor = [UIColor colorWithWhite:0.86 alpha:1.0];
    self.topBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topBorder];
}


- (void)setupConstraints
{
    CGFloat contentPad = self.config.contentPadding;
    CGFloat btnTopInset = self.config.closeButtonTopInset;
    CGFloat btnSideInset = self.config.closeButtonSideInset;
    CGFloat scrollBtnGap = self.config.closeButtonToScrollGap;
    CGFloat closeBtnSize = self.config.closeButtonSize;
    
    
    [NSLayoutConstraint activateConstraints:@[
        /* grey separator */
        [self.topBorder.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.topBorder.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.topBorder.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.topBorder.heightAnchor constraintEqualToConstant:self.config.borderHeight],
        
        /* ✕ button */
        [self.closeBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant: btnTopInset],
        [self.closeBtn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant: -btnSideInset],
        [self.closeBtn.widthAnchor constraintEqualToConstant:closeBtnSize],
        [self.closeBtn.heightAnchor constraintEqualToAnchor:self.closeBtn.widthAnchor],
        
        /* scroll container */
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.topAnchor constraintEqualToAnchor:self.closeBtn.bottomAnchor constant: scrollBtnGap],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        /* content inside scroll */
        [self.contentView.leadingAnchor  constraintEqualToAnchor:self.scroll.leadingAnchor constant: contentPad],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scroll.trailingAnchor constant: -contentPad],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scroll.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scroll.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scroll.widthAnchor constant: -2 * contentPad],
    ]];
}


- (CGSize)preferredContentSize
{
    [self.view layoutIfNeeded];
    CGFloat header  = CGRectGetMinY(self.scroll.frame) + self.view.safeAreaInsets.bottom;
    CGFloat natural = header + self.scroll.contentSize.height;
    CGFloat presentingViewHeight = self.presentingViewController.view.bounds.size.height;
    CGFloat minH = self.config.minHeightMultiplier * presentingViewHeight;
    CGFloat maxH = self.config.maxHeightMultiplier * presentingViewHeight;
    CGFloat sheetH = MAX(minH, MIN(natural, maxH));
    self.scroll.scrollEnabled = natural > sheetH;
    self.scroll.alwaysBounceVertical = self.scroll.scrollEnabled;
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
