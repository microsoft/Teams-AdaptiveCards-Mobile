
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
        [self setup:expandable];
    }
    return self;
}

- (void)setup:(BOOL)expandable
{
    // Set the title font (system font with a point size of 15)
    self.titleLabel.font = [UIFont systemFontOfSize:15];

    // Set the auto resizing mask
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Custom runtime attributes translated as properties on ACRButton:
    self.positiveForegroundColor = [UIColor colorWithWhite:0.6666666667 alpha:1.0];
    self.positiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.destructiveForegroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    self.destructiveBackgroundColor = [UIColor colorWithWhite:0.3333333333 alpha:1.0];
    self.positiveUseDefault = YES;
    self.destructiveUseDefault = NO;

    // Set this to avoid unexpected external modification to background color break the style.
    self.layer.cornerRadius = 10;

    // Create a filled button configuration
    UIButtonConfiguration *buttonConfig = [UIButtonConfiguration filledButtonConfiguration];

    // Set the default background and title colors
    buttonConfig.baseBackgroundColor = UIColor.systemBlueColor;
    buttonConfig.baseForegroundColor = UIColor.systemBackgroundColor; // title color

    // Set the default content insets (10 on all sides)
    buttonConfig.contentInsets = NSDirectionalEdgeInsetsMake(10, 10, 10, 10);

    // Set the default corner radius on the background configuration
    buttonConfig.background.cornerRadius = 10;

    if (expandable) {
        // Prepare images for different states
        UIImage *chevronUp = [UIImage systemImageNamed:@"chevron.up"];
        UIImage *chevronDown = [UIImage systemImageNamed:@"chevron.down"];

        // Set a default image (for the normal state)
        buttonConfig.image = chevronUp;

        self.configurationUpdateHandler = ^(__kindof UIButton *_Nonnull button) {
            UIButtonConfiguration *updatedConfig = button.configuration;
            if (button.isSelected) {
                updatedConfig.image = chevronDown;
            } else {
                updatedConfig.image = chevronUp;
            }
            // Re-assign the updated configuration back to the button
            button.configuration = updatedConfig;
        };
    }

    self.configuration = buttonConfig;
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
    float ratio = 1.0f;
    CGSize contentSize = self.titleLabel.intrinsicContentSize;

    // apply explicit image size when the below condition is met
    if (_iconPlacement == ACRAboveTitle) {
        imageHeight = [config getHostConfig]->GetActions().iconSize;
    } else { // format the image so it fits in the button
        imageHeight = contentSize.height;
    }

    if (image && image.size.height > 0) {
        ratio = image.size.width / image.size.height;
    }

    CGSize imageSize = CGSizeMake(imageHeight * ratio, imageHeight);

    UIButtonConfiguration *buttonConfiguration = self.configuration;

    buttonConfiguration.image = image;

    // Resize the image to desired size
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
    buttonConfiguration.image = [[renderer imageWithActions:^(__unused UIGraphicsImageRendererContext *_Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    }] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    // Set the image on the button
    buttonConfiguration.imagePadding = [config getHostConfig]->GetSpacing().defaultSpacing;

    if (_iconPlacement == ACRAboveTitle) {
        // Set the image placement to the top
        buttonConfiguration.imagePlacement = NSDirectionalRectEdgeTop;
    } else {
        // Otherwise, set the image placement to the leading edge
        buttonConfiguration.imagePlacement = NSDirectionalRectEdgeLeading;
    }

    self.configuration = buttonConfiguration;
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
    std::vector<std::shared_ptr<AdaptiveCards::BaseActionElement>> menuActions = action->GetMenuActions();
    NSDictionary *imageViewMap = [rootView getImageMap];
    NSString *iconURL = [NSString stringWithCString:action->GetIconUrl().c_str() encoding:[NSString defaultCStringEncoding]];
    NSString *key = iconURL;
    UIImage *image = imageViewMap[key];
    button.iconPlacement = [ACRButton getIconPlacmentAtCurrentContext:rootView url:key];

    if (image) {
        [button setImageView:image withConfig:config];
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
            [ACRSVGImageView requestIcon:getSVGURL
                                  filled:isFilled
                                    size:CGSizeMake(imageHeight, imageHeight)
                                     rtl:rootView.context.rtl
                              completion:^(UIImage *icon) {
                                  [button setImageView:icon withConfig:config widthToHeightRatio:1.0f];
                              }];
        } else if (view) {
            if (view.image) {
                [button setImageView:view.image withConfig:config];
                [rootView removeObserverOnImageView:@"image" onObject:view keyToImageView:k];
            }
        }
    }
    
    if (!menuActions.empty())
    {
        button.iconPlacement = ACRRightOfTitle;
        NSString *chevronDownIcon = @"ChevronDown";
        NSString *url = [[NSString alloc] initWithFormat:@"%@%@/%@.json", baseFluentIconCDNURL, chevronDownIcon, chevronDownIcon];
        UIImageView *view = [[ACRSVGImageView alloc] init:url rtl:rootView.context.rtl isFilled:true size:CGSizeMake(12, 12) tintColor:button.currentTitleColor];
        button.iconView = view;
        [button addSubview:view];
        [button setImageView:view.image withConfig:config widthToHeightRatio:1.0f];
    }
    
    if (button.isEnabled == NO) {
        UIButtonConfiguration *buttonConfiguration = button.configuration;
        buttonConfiguration.baseBackgroundColor = [buttonConfiguration.baseBackgroundColor colorWithAlphaComponent:0.5];
        button.configuration = buttonConfiguration;
    }

    return button;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    UIButtonConfiguration *buttonConfiguration = self.configuration;
    buttonConfiguration.baseBackgroundColor = backgroundColor;
    self.configuration = buttonConfiguration;
}

- (void)applySentimentStyling
{
    UIButtonConfiguration *buttonConfiguration = self.configuration;
    if ([@"positive" caseInsensitiveCompare:_sentiment] == NSOrderedSame) {
        // By default, positive sentiment must have background accentColor and white text/foreground color
        if (_positiveUseDefault) {
            buttonConfiguration.baseBackgroundColor = _defaultPositiveBackgroundColor;
            buttonConfiguration.baseForegroundColor = UIColor.whiteColor;
        } else {
            // Otherwise use the defined values
            buttonConfiguration.baseBackgroundColor = _positiveBackgroundColor;
            buttonConfiguration.baseForegroundColor = _positiveForegroundColor;
        }
    } else if ([@"destructive" caseInsensitiveCompare:_sentiment] == NSOrderedSame) {
        // By default, destructive sentiment must have a attention text/foreground color
        if (_destructiveUseDefault) {
            buttonConfiguration.baseForegroundColor = _defaultDestructiveForegroundColor;
        } else {
            // Otherwise use the defined values
            buttonConfiguration.baseBackgroundColor = _destructiveBackgroundColor;
            buttonConfiguration.baseForegroundColor = _destructiveForegroundColor;
        }
    }
    self.configuration = buttonConfiguration;
}

- (BOOL)doesItHaveAnImageView
{
    return (self.actionType == ACRShowCard && self.imageView && self.imageView.frame.size.width);
}

+ (ACRIconPlacement)getIconPlacementAtCurrentContext:(ACRView *)rootView url:(NSString *)key doesHaveMenuActions:(BOOL)doesContainMenuActions
{
    if (!key or key.length == 0) {
        return ACRNoTitle;
    }

    if ([rootView.context.hostConfig getIconPlacement] == ACRAboveTitle and rootView.context.allHasActionIcons) {
        return ACRAboveTitle;
    }

    return doesContainMenuActions ? ACRRightOfTitle : ACRLeftOfTitle;
}

@end
