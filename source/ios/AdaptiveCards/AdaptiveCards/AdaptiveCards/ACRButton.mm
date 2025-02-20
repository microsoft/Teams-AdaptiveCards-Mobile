//
//  ACRButton
//  ACRButton.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRButton.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOBundle.h"
#import "ACOHostConfigPrivate.h"
#import "ACRSVGImageView.h"
#import "ACRUIImageView.h"
#import "ACRViewPrivate.h"
#import "UtiliOS.h"

@implementation ACRButton

- (instancetype)initWithExpandable:(BOOL)expandable
{
    self = [super init];
    if (self) {
        if (expandable) {
            [self setupExpandableConfig];
        } else {
            [self setupDefaultConfig];
        }
    }
    return self;
}

- (void)setupExpandableConfig
{
    self.backgroundColor = UIColor.systemBlueColor;
    self.tintColor = UIColor.systemBackgroundColor;

    // Configure autoresizing mask
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                            UIViewAutoresizingFlexibleHeight;

    // Set content insets (10 on all sides)
    self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);

    // Set the title font (system font with a point size of 15)
    self.titleLabel.font = [UIFont systemFontOfSize:15];

    // Set images for various button states using SF Symbols (iOS 13+)
    if (@available(iOS 13.0, *)) {
        UIImage *chevronUp = [UIImage systemImageNamed:@"chevron.up"];
        UIImage *chevronDown = [UIImage systemImageNamed:@"chevron.down"];
        
        [self setImage:chevronUp forState:UIControlStateNormal];
        [self setImage:chevronUp forState:UIControlStateDisabled];
        [self setImage:chevronDown forState:UIControlStateSelected];
        [self setImage:chevronUp forState:UIControlStateHighlighted];
    }

    // Set title color for normal state to white
    [self setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];

    // Set corner radius
    self.layer.cornerRadius = 10;

    // Custom runtime attributes translated as properties
    self.positiveForegroundColor = [UIColor colorWithWhite:0.6666666667 alpha:1.0];
    self.positiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.destructiveForegroundColor = [UIColor colorWithWhite:1 alpha:1];
    self.destructiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.positiveUseDefault = YES;
    self.destructiveUseDefault = NO;
}

- (void)setupDefaultConfig
{
    self.backgroundColor = UIColor.systemBlueColor;
    self.tintColor = UIColor.systemBlueColor;

    // Configure autoresizing mask
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                            UIViewAutoresizingFlexibleHeight;

    // Content insets of 10 on all sides.
    self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);

    // Set title color for normal state to white.
    [self setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];

    // Set corner radius.
    self.layer.cornerRadius = 10;

    // Custom runtime attributes translated as properties on ACRButton:
    self.positiveForegroundColor = [UIColor colorWithWhite:0.6666666667 alpha:1.0];
    self.positiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.destructiveForegroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    self.destructiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.positiveUseDefault = YES;
    self.destructiveUseDefault = NO;
}

- (void)setImageView:(UIImage *)image
          withConfig:(ACOHostConfig *)config
{
    [self setImageView:image withConfig:config widthToHeightRatio:0.0f];
}

- (void)setImageView:(UIImage *)image
            withConfig:(ACOHostConfig *)config
    widthToHeightRatio:(float)widthToHeightRatio
{
    float imageHeight = 0.0f;
    CGSize contentSize = [self.titleLabel intrinsicContentSize];

    // apply explicit image size when the below condition is met
    if (_iconPlacement == ACRAboveTitle) {
        imageHeight = [config getHostConfig]->GetActions().iconSize;
    } else { // format the image so it fits in the button
        imageHeight = contentSize.height;
    }

    if (image && image.size.height > 0) {
        widthToHeightRatio = image.size.width / image.size.height;
    }

    CGSize imageSize = CGSizeMake(imageHeight * widthToHeightRatio, imageHeight);
    _iconView.translatesAutoresizingMaskIntoConstraints = NO;

    // scale the image using UIImageView
    [NSLayoutConstraint constraintWithItem:_iconView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:imageSize.width]
        .active = YES;

    [NSLayoutConstraint constraintWithItem:_iconView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:imageSize.height]
        .active = YES;

    int iconPadding = [config getHostConfig]->GetSpacing().defaultSpacing;

    if (_iconPlacement == ACRAboveTitle) {
        // fix image view to top and center x of the button
        [NSLayoutConstraint constraintWithItem:_iconView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:self.contentEdgeInsets.top]
            .active = YES;
        [NSLayoutConstraint constraintWithItem:_iconView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0]
            .active = YES;
        // image can't be postion at the top of the title, so adjust title inset edges
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, iconPadding, -imageHeight - iconPadding, 0)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -imageHeight - iconPadding, 0)];
        CGFloat insetConstant = (imageSize.height + iconPadding) / 2;
        [self setContentEdgeInsets:UIEdgeInsetsMake(self.contentEdgeInsets.top + insetConstant, 0, self.contentEdgeInsets.bottom + insetConstant, 0)];
    } else if (_iconPlacement != ACRNoTitle) {
        int npadding = 0;
        if (self.doesItHaveAnImageView) {
            iconPadding += (self.imageView.frame.size.width + iconPadding);
            npadding = [config getHostConfig]->GetSpacing().defaultSpacing;
        }
        CGFloat widthOffset = (imageSize.width + iconPadding);

        [self setContentEdgeInsets:UIEdgeInsetsMake(self.contentEdgeInsets.top, self.contentEdgeInsets.left + widthOffset / 2, self.contentEdgeInsets.bottom, self.contentEdgeInsets.right + widthOffset / 2)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, npadding, 0, -(widthOffset + npadding))];
        [_iconView.trailingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor constant:-iconPadding].active = YES;

        [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0].active = YES;
        CGFloat offset = -(self.contentEdgeInsets.left + self.contentEdgeInsets.right);

        self.titleWidthConstraint = [self.titleLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor constant:offset];
        self.titleWidthConstraint.active = YES;

        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:(widthOffset / 2)].active = YES;

        self.heightConstraint = [self.heightAnchor constraintGreaterThanOrEqualToAnchor:self.titleLabel.heightAnchor constant:self.contentEdgeInsets.top + self.contentEdgeInsets.bottom];
        self.heightConstraint.active = YES;
    }
}

+ (UIButton *)rootView:(ACRView *)rootView
     baseActionElement:(ACOBaseActionElement *)acoAction
                 title:(NSString *)title
         andHostConfig:(ACOHostConfig *)config
{
    ACRButton *button = [[ACRButton alloc] initWithExpandable:[acoAction type] == ACRShowCard];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.adjustsFontSizeToFitWidth = NO;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.adjustsFontForContentSizeCategory = YES;
    if (button.titleLabel.font) {
        button.titleLabel.font = [UIFontMetrics.defaultMetrics scaledFontForFont:button.titleLabel.font];
    } else {
        button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }

    button.isAccessibilityElement = YES;
    button.accessibilityLabel = title;
    button.enabled = [acoAction isEnabled];

    button.sentiment = acoAction.sentiment;
    button.actionType = acoAction.type;

    button.defaultPositiveBackgroundColor = [config getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:(ForegroundColor::Accent)subtleOption:false];
    button.defaultDestructiveForegroundColor = [config getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:(ForegroundColor::Attention)subtleOption:false];
    [button applySentimentStyling];

    std::shared_ptr<AdaptiveCards::BaseActionElement> action = [acoAction element];
    NSDictionary *imageViewMap = [rootView getImageMap];
    NSString *iconURL = [NSString stringWithCString:action->GetIconUrl().c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *key = iconURL;
    UIImage *img = imageViewMap[key];
    button.iconPlacement = [ACRButton getIconPlacmentAtCurrentContext:rootView url:key];

    if (img) {
        UIImageView *iconView = [[ACRUIImageView alloc] init];
        iconView.image = img;
        [button addSubview:iconView];
        button.iconView = iconView;
        [button setImageView:img withConfig:config];
    } else if (key.length) {
        NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)action.get()];
        NSString *k = [number stringValue];
        UIImageView *view = [rootView getImageView:k];
        if ([iconURL hasPrefix:@"icon:"]) {
            // Rendering svg fluent icon here on button

            // intentionally kept this 24 so that it always loads
            // irrespective of size given in host config.
            // it is possible that host config has some size which is not available in CDN.
            unsigned int imageHeight = 24;
            BOOL isFilled = [[iconURL lowercaseString] containsString:@"filled"];
            NSString *getSVGURL = cdnURLForIcon(@(action->GetSVGPath().c_str()));
            UIImageView *v = [[ACRSVGImageView alloc] init:getSVGURL rtl:rootView.context.rtl isFilled:isFilled size:CGSizeMake(imageHeight, imageHeight) tintColor:button.currentTitleColor];
            button.iconView = v;
            [button addSubview:v];
            [button setImageView:view.image withConfig:config widthToHeightRatio:1.0f];
        } else if (view) {
            if (view.image) {
                button.iconView = view;
                [button addSubview:view];
                [rootView removeObserverOnImageView:@"image" onObject:view keyToImageView:k];
                [button setImageView:view.image withConfig:config];
            } else {
                button.iconView = view;
                [button addSubview:view];
                [rootView setImageView:k view:button];
            }
        }
    } else {
        button.heightConstraint = [button.heightAnchor constraintGreaterThanOrEqualToAnchor:button.titleLabel.heightAnchor constant:button.contentEdgeInsets.top + button.contentEdgeInsets.bottom];
        button.heightConstraint.active = YES;
    }

    if (button.isEnabled == NO) {
        [button setBackgroundColor:[button.backgroundColor colorWithAlphaComponent:0.5]];
    }

    return button;
}

- (void)applySentimentStyling
{
    if ([@"positive" caseInsensitiveCompare:_sentiment] == NSOrderedSame) {
        BOOL usePositiveDefault = _positiveUseDefault;

        // By default, positive sentiment must have background accentColor and white text/foreground color
        if (usePositiveDefault) {
            [self setBackgroundColor:_defaultPositiveBackgroundColor];
            [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        } else {
            // Otherwise use the values defined by the user in the ACRButton.xib
            [self setBackgroundColor:_positiveBackgroundColor];
            [self setTitleColor:_positiveForegroundColor forState:UIControlStateNormal];
        }
    } else if ([@"destructive" caseInsensitiveCompare:_sentiment] == NSOrderedSame) {
        BOOL useDestructiveDefault = _destructiveUseDefault;

        // By default, destructive sentiment must have a attention text/foreground color
        if (useDestructiveDefault) {
            [self setTitleColor:_defaultDestructiveForegroundColor forState:UIControlStateNormal];
        } else {
            // Otherwise use the values defined by the user in the ACRButton.xib
            [self setBackgroundColor:_destructiveBackgroundColor];
            [self setTitleColor:_destructiveForegroundColor forState:UIControlStateNormal];
        }
    }
}

- (BOOL)doesItHaveAnImageView
{
    return (self.actionType == ACRShowCard && self.imageView && self.imageView.frame.size.width);
}

+ (ACRIconPlacement)getIconPlacmentAtCurrentContext:(ACRView *)rootView url:(NSString *)key
{
    if (!key or key.length == 0) {
        return ACRNoTitle;
    }

    if ([rootView.context.hostConfig getIconPlacement] == ACRAboveTitle and rootView.context.allHasActionIcons) {
        return ACRAboveTitle;
    }

    return ACRLeftOfTitle;
}

@end
