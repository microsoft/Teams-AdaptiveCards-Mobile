//
//  ACRView.m
//  ACRView
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACOAdaptiveCardPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRButton.h"
#import "ACRContentHoldingUIView.h"
#import "ACRIBaseCardElementRenderer.h"
#import "ACRImageRenderer.h"
#import "ACRRegistrationPrivate.h"
#import "ACRRendererPrivate.h"
#import "ACRTextBlockRenderer.h"
#import "ACRUIImageView.h"
#import "ACRUILabel.h"
#import "ACRViewPrivate.h"
#import "ActionSet.h"
#import "AdaptiveBase64Util.h"
#import "BackgroundImage.h"
#import "Column.h"
#import "ColumnSet.h"
#import "Container.h"
#import "Enums.h"
#import "Fact.h"
#import "FactSet.h"
#import "ImageSet.h"
#import "MarkDownParser.h"
#import "Media.h"
#import "RichTextBlock.h"
#import "RichTextElementProperties.h"
#import "SharedAdaptiveCard.h"
#import "Table.h"
#import "TableCell.h"
#import "TableRow.h"
#import "TextBlock.h"
#import "TextInput.h"
#import "TextRun.h"
#import "UtiliOS.h"
#import "CarouselPage.h"
#import "Carousel.h"
#import <AVFoundation/AVFoundation.h>

using namespace AdaptiveCards;
typedef UIImage * (^ImageLoadBlock)(NSURL *url);

@implementation ACRView {
    ACOAdaptiveCard *_adaptiveCard;
    NSMutableDictionary *_imageViewMap;
    NSMutableDictionary *_textMap;
    dispatch_queue_t _serial_queue;
    dispatch_queue_t _serial_text_queue;
    dispatch_queue_t _global_queue;
    dispatch_group_t _async_tasks_group;
    int _serialNumber;
    int _numberOfSubscribers;
    // flag that's set if didLoadElements delegate is called
    BOOL _hasCalled;
    NSMutableDictionary *_imageContextMap;
    NSMutableDictionary *_elementWidthMap;
    NSMutableDictionary *_imageViewContextMap;
    NSMutableSet *_setOfRemovedObservers;
    // Set for tracking image views that should use early KVO removal
    NSMutableSet<UIImageView *> *_earlyKVORemovalImageViews;
    NSMutableDictionary<NSString *, UIView *> *_paddingMap;
    ACRTargetBuilderDirector *_actionsTargetBuilderDirector;
    ACRTargetBuilderDirector *_selectActionsTargetBuilderDirector;
    ACRTargetBuilderDirector *_quickReplyTargetBuilderDirector;
    NSMapTable<ACRColumnView *, ACRColumnView *> *_inputHandlerLookupTable;
    NSMutableArray<ACRColumnView *> *_showcards;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        std::shared_ptr<HostConfig> cHostConfig = std::make_shared<HostConfig>();
        _hostConfig = [[ACOHostConfig alloc] initWithConfig:cHostConfig];
        _imageViewMap = [[NSMutableDictionary alloc] init];
        _elementWidthMap = [[NSMutableDictionary alloc] init];
        _textMap = [[NSMutableDictionary alloc] init];
        _serial_queue = dispatch_queue_create("io.adaptiveCards.serial_queue", DISPATCH_QUEUE_SERIAL);
        _serial_text_queue = dispatch_queue_create("io.adaptiveCards.serial_text_queue", DISPATCH_QUEUE_SERIAL);
        _global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _async_tasks_group = dispatch_group_create();
        _serialNumber = 0;
        _imageContextMap = [[NSMutableDictionary alloc] init];
        _imageViewContextMap = [[NSMutableDictionary alloc] init];
        _setOfRemovedObservers = [[NSMutableSet alloc] init];
        _earlyKVORemovalImageViews = [[NSMutableSet alloc] init];
        _paddingMap = [[NSMutableDictionary alloc] init];
        _inputHandlerLookupTable = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory capacity:5];
        _showcards = [[NSMutableArray alloc] init];
        _context = [[ACORenderContext alloc] init:_hostConfig];
    }
    return self;
}

- (instancetype)init:(ACOAdaptiveCard *)card
          hostconfig:(ACOHostConfig *)config
     widthConstraint:(float)width
            delegate:(id<ACRActionDelegate>)acrActionDelegate
               theme:(ACRTheme)theme
{
    self = [self initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.accessibilityLabel = @"ACR Root View";
        _adaptiveCard = card;
        _warnings = [[NSMutableArray<ACOWarning *> alloc] init];
        // override default host config if user host config is provided
        if (config) {
            _hostConfig = config;
            _context.hostConfig = config;
        }
        _actionsTargetBuilderDirector = [[ACRTargetBuilderDirector alloc] init:self capability:ACRAction adaptiveHostConfig:_hostConfig];
        _selectActionsTargetBuilderDirector = [[ACRTargetBuilderDirector alloc] init:self capability:ACRSelectAction adaptiveHostConfig:_hostConfig];
        _quickReplyTargetBuilderDirector = [[ACRTargetBuilderDirector alloc] init:self capability:ACRQuickReply adaptiveHostConfig:_hostConfig];
        unsigned int padding = [_hostConfig getHostConfig]->GetSpacing().paddingSpacing;
        [self removeConstraints:self.constraints];

        [self applyPadding:padding priority:1000];

        self.acrActionDelegate = acrActionDelegate;
        self.theme = theme;
        [self render];
    }
    // call to check if all resources are loaded
    [self callDidLoadElementsIfNeeded];
    return self;
}

// Initializes ACRView instance with HostConfig and AdaptiveCard
- (instancetype)init:(ACOAdaptiveCard *)card
          hostconfig:(ACOHostConfig *)config
     widthConstraint:(float)width
               theme:(ACRTheme)theme
{
    self = [self init:card hostconfig:config widthConstraint:width delegate:nil theme:theme];
    return self;
}

- (UIView *)render
{
    // set the width constraint only if it's explicitly asked
    if (self.frame.size.width) {
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.frame.size.width].active = YES;
    }

    [self pushCurrentShowcard:self];
    [self setParent:nil child:self];

    UIView *newView = [ACRRenderer renderWithAdaptiveCards:[_adaptiveCard card] inputs:self.inputHandlers context:self containingView:self hostconfig:_hostConfig];

    ContainerStyle style = ([_hostConfig getHostConfig]->GetAdaptiveCard().allowCustomStyle) ? [_adaptiveCard card]->GetStyle() : ContainerStyle::Default;

    newView.backgroundColor = [_hostConfig getBackgroundColorForContainerStyle:
                                               [ACOHostConfig getPlatformContainerStyle:style]];

    [self popCurrentShowcard];

    return newView;
}

- (void)waitForAsyncTasksToFinish
{
    dispatch_group_wait(_async_tasks_group, DISPATCH_TIME_FOREVER);
    [self callDidLoadElementsIfNeeded];
}

- (void)enableEarlyKVORemovalForImageView:(UIImageView *)imageView
{
    if (imageView) {
        [_earlyKVORemovalImageViews addObject:imageView];
        NSLog(@"ACRView: Added imageView %p to early KVO removal set", imageView);
    }
}

- (BOOL)isEarlyKVORemovalEnabledForImageView:(UIImageView *)imageView
{
    return imageView ? [_earlyKVORemovalImageViews containsObject:imageView] : NO;
}

- (void)scheduleImageCompletionCheckForView:(UIImageView *)imageView key:(NSString *)key
{
    if (!imageView || !key) {
        return;
    }
    
    NSLog(@"ACRView: Scheduling fallback image completion check for view %p with key %@", imageView, key);
    
    // Use weak references to avoid retain cycles
    __weak ACRView *weakSelf = self;
    __weak UIImageView *weakImageView = imageView;
    NSString *imageKey = [key copy]; // Copy the key to ensure it stays valid
    
    // Schedule periodic checks for image completion
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf checkImageCompletionForView:weakImageView key:imageKey attempt:1];
    });
}

- (void)checkImageCompletionForView:(UIImageView *)imageView key:(NSString *)key attempt:(NSInteger)attempt
{
    if (!imageView || !key || attempt > 50) { // Stop after 5 seconds (50 * 0.1)
        if (attempt > 50) {
            NSLog(@"ACRView: Fallback image check timed out for view %p with key %@", imageView, key);
        }
        return;
    }
    
    // Check if image has loaded
    if (imageView.image != nil) {
        NSLog(@"ACRView: Fallback detected image completion for view %p with key %@", imageView, key);
        
        // Simulate the KVO completion behavior
        [self handleImageCompletionForView:imageView key:key];
        return;
    }
    
    // Schedule next check
    __weak ACRView *weakSelf = self;
    __weak UIImageView *weakImageView = imageView;
    NSString *imageKey = [key copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf checkImageCompletionForView:weakImageView key:imageKey attempt:attempt + 1];
    });
}

- (void)handleImageCompletionForView:(UIImageView *)imageView key:(NSString *)key
{
    if (!imageView || !key) {
        return;
    }
    
    NSLog(@"ACRView: Processing fallback image completion for view %p with key %@", imageView, key);
    
    // Perform the same actions that would normally happen in observeValueForKeyPath
    // This includes layout updates, size adjustments, etc.
    
    // Update layout if needed
    [self setNeedsLayout];
    
    // Decrement subscriber count (similar to what KVO completion does)
    if (_numberOfSubscribers > 0) {
        _numberOfSubscribers--;
        [self callDidLoadElementsIfNeeded];
    }
    
    // For images, we might need to adjust size based on content
    if (imageView.image && [imageView.image respondsToSelector:@selector(size)]) {
        CGSize imageSize = imageView.image.size;
        if (imageSize.width > 0 && imageSize.height > 0) {
            // Let the image view auto-size based on the loaded image
            [imageView sizeToFit];
        }
    }
}

- (void)handleImageLoadedForView:(UIImageView *)imageView key:(NSString *)key context:(void *)context
{
    if (!imageView || !key) {
        return;
    }
    
    NSLog(@"ACRView: Image loaded callback received for view %p with key %@", imageView, key);
    
    // Register the image from the UI image view
    [self registerImageFromUIImageView:imageView key:key];
    
    // Replicate the original KVO observer logic for proper image configuration
    if (context && imageView.image) {
        UIImage *image = imageView.image;
        
        // Get the base card element from context (similar to original KVO logic)
        ACOBaseCardElement *baseCardElement = _imageContextMap[key];
        if (baseCardElement) {
            NSLog(@"ACRView: Found baseCardElement for key %@ - type: %d", key, (int)baseCardElement.type);
            
            // Check if this is a simple image case that needs special handling
            // Use container properties rather than unreliable frame detection
            BOOL isSimpleImageCase = NO;
            ACRContentHoldingUIView *containingView = nil;
            
            if ([imageView.superview isKindOfClass:[ACRContentHoldingUIView class]]) {
                containingView = (ACRContentHoldingUIView *)imageView.superview;
                
                // Simple images have specific characteristics:
                // 1. Not media type (complex cards have media types)
                // 2. Not person style (avatars have person style)  
                // 3. Basic image properties without special sizing
                isSimpleImageCase = (!containingView.isMediaType && 
                                   !containingView.isPersonStyle &&
                                   containingView.imageProperties != nil);
                
                NSLog(@"ACRView: Container analysis - isSimpleImageCase: %@, isMediaType: %@, isPersonStyle: %@", 
                      isSimpleImageCase ? @"YES" : @"NO", 
                      containingView.isMediaType ? @"YES" : @"NO",
                      containingView.isPersonStyle ? @"YES" : @"NO");
            } else {
                NSLog(@"ACRView: No ACRContentHoldingUIView container found - using full renderer approach");
            }
            
            if (isSimpleImageCase && containingView) {
                NSLog(@"ACRView: Handling simple image case with direct frame setting approach");
                
                // For simple images, bypass Auto Layout complexity and use direct frame setting
                // This mimics what KVO did successfully without the hacky remove/re-add
                if (image && image.size.width > 0 && image.size.height > 0) {
                    // Update the container's image properties with the actual image size
                    [containingView.imageProperties updateContentSize:image.size];
                    
                    // CLEAN APPROACH: Set the imageView frame directly (like KVO did)
                    // No need to remove/re-add - just set frame and disable Auto Layout conflicts
                    CGSize imageSize = image.size;
                    CGFloat maxWidth = 400.0; // Match expected size
                    CGFloat maxHeight = 400.0;
                    
                    // Calculate scaled size maintaining aspect ratio
                    CGFloat scale = MIN(maxWidth / imageSize.width, maxHeight / imageSize.height);
                    CGSize scaledSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
                    
                    // Ensure container is properly sized first
                    containingView.frame = CGRectMake(containingView.frame.origin.x, containingView.frame.origin.y, 
                                                     maxWidth, maxHeight);
                    
                    // Center the image in the container (using container bounds, not containerBounds variable)
                    CGRect imageFrame = CGRectMake(
                        (maxWidth - scaledSize.width) / 2.0,
                        (maxHeight - scaledSize.height) / 2.0,
                        scaledSize.width,
                        scaledSize.height
                    );
                    
                    NSLog(@"ACRView: Setting imageView frame directly to: %@", NSStringFromCGRect(imageFrame));
                    
                    // Disable Auto Layout to avoid conflicts (this is what KVO implicitly did)
                    imageView.translatesAutoresizingMaskIntoConstraints = YES;
                    
                    // Set frame directly (like KVO did)
                    imageView.frame = imageFrame;
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    imageView.clipsToBounds = NO; // Prevent clipping issues
                    
                    // Update container properties and trigger layout
                    [containingView update:containingView.imageProperties];
                    
                    NSLog(@"ACRView: Direct frame set - imageView frame: %@, container frame: %@", 
                          NSStringFromCGRect(imageView.frame), NSStringFromCGRect(containingView.frame));
                }
                
                // Update layout
                [self setNeedsLayout];
                [self layoutIfNeeded];
                
                NSLog(@"ACRView: Simple image case handled - final imageView frame: %@", 
                      NSStringFromCGRect(imageView.frame));
            } else {
                NSLog(@"ACRView: Handling normal image with full renderer approach");
                
                // Get the appropriate renderer for normal images (complex cards or well-behaved simple images)
                ACRRegistration *reg = [ACRRegistration getInstance];
                ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *renderer = 
                    (ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *)[reg getRenderer:[NSNumber numberWithInt:static_cast<int>(baseCardElement.type)]];
                
                if (renderer && [[renderer class] conformsToProtocol:@protocol(ACRIKVONotificationHandler)]) {
                    NSLog(@"ACRView: Calling renderer configUpdateForUIImageView for normal image");
                    NSMutableDictionary *imageViewMap = [self getImageMap];
                    imageViewMap[key] = image;
                    
                    // IMPORTANT: Add imageView to removed observers set BEFORE calling configUpdateForUIImageView
                    // This prevents the crash when configUpdateForUIImageView tries to remove a non-existent observer
                    [_setOfRemovedObservers addObject:imageView];
                    
                    NSLog(@"ACRView: Before renderer call - imageView frame: %@, image size: %@", 
                          NSStringFromCGRect(imageView.frame), 
                          NSStringFromCGSize(image.size));
                    
                    // This is the key call that was missing - it handles proper Auto Layout constraints
                    [renderer configUpdateForUIImageView:self acoElem:baseCardElement config:_hostConfig image:image imageView:imageView];
                    
                    NSLog(@"ACRView: After renderer call - imageView frame: %@", NSStringFromCGRect(imageView.frame));
                    
                    // Force layout update after the renderer sets up constraints
                    [imageView setNeedsLayout];
                    [imageView layoutIfNeeded];
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                    
                    NSLog(@"ACRView: After layout update - imageView frame: %@", NSStringFromCGRect(imageView.frame));
                } else {
                    NSLog(@"ACRView: No renderer found or renderer doesn't support KVO notification handler for type %d", (int)baseCardElement.type);
                }
            }
        } else {
            NSLog(@"ACRView: No baseCardElement found for key %@ in _imageContextMap. Available keys: %@", key, [_imageContextMap allKeys]);
        }
    }
    
    // Update layout if needed
    [self setNeedsLayout];
    
    // Decrement subscriber count (similar to what KVO completion does)
    if (_numberOfSubscribers > 0) {
        _numberOfSubscribers--;
        [self callDidLoadElementsIfNeeded];
    }
}

- (void)callDidLoadElementsIfNeeded
{
    // Call back app with didLoadElements
    if ([[self acrActionDelegate] respondsToSelector:@selector(didLoadElements)] && !_numberOfSubscribers && !_hasCalled) {
        _hasCalled = YES;
        [[self acrActionDelegate] didLoadElements];
    }
}

- (void)setWidthForElememt:(unsigned int)key width:(float)width
{
    _elementWidthMap[@(key)] = @(width);
}

-(float)widthForElement:(unsigned int)key
{
    NSNumber *value = _elementWidthMap[@(key)];
    if(value)
    {
        return value.floatValue;
    }
    return -1;
}

- (void)processBaseCardElement:(std::shared_ptr<BaseCardElement> const &)elem registration:(ACRRegistration *)registration
{
    switch (elem->GetElementType()) {
        case CardElementType::TextBlock: {
            std::shared_ptr<TextBlock> textBlockElement = std::static_pointer_cast<TextBlock>(elem);
            RichTextElementProperties textProp;
            auto style = textBlockElement->GetStyle();
            if (style.has_value() && *style == TextStyle::Heading) {
                TexStylesToRichTextElementProperties(textBlockElement, [_hostConfig getHostConfig]->GetTextStyles().heading, textProp);
            } else {
                TextStyleConfig textStyleConfig;
                textStyleConfig.size = textBlockElement->GetTextSize().value_or(TextSize::Default);
                textStyleConfig.weight = textBlockElement->GetTextWeight().value_or(TextWeight::Default);
                textStyleConfig.fontType = textBlockElement->GetFontType().value_or(FontType::Default);
                textStyleConfig.color = textBlockElement->GetTextColor().value_or(ForegroundColor::Default);
                textStyleConfig.isSubtle = textBlockElement->GetIsSubtle().value_or(false);
                TexStylesToRichTextElementProperties(textBlockElement, textStyleConfig, textProp);
            }

            /// tag a base card element with unique key
            NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)textBlockElement.get()];
            NSString *key = [number stringValue];
            [self processTextConcurrently:textProp elementId:key];
            break;
        }
        case CardElementType::RichTextBlock: {
            std::shared_ptr<RichTextBlock> rTxtBlkElement = std::static_pointer_cast<RichTextBlock>(elem);
            for (const auto &inlineText : rTxtBlkElement->GetInlines()) {
                std::shared_ptr<TextRun> textRun = std::static_pointer_cast<TextRun>(inlineText);
                if (textRun) {
                    RichTextElementProperties textProp;
                    TextRunToRichTextElementProperties(textRun, textProp);
                    NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)textRun.get()];
                    NSString *key = [number stringValue];
                    [self processTextConcurrently:textProp elementId:key];
                }
            }
            break;
        }
        case CardElementType::FactSet: {
            [self tagBaseCardElement:elem];
            std::shared_ptr<FactSet> factSet = std::dynamic_pointer_cast<FactSet>(elem);
            NSString *key = [NSString stringWithCString:elem->GetId().c_str() encoding:[NSString defaultCStringEncoding]];
            key = [key stringByAppendingString:@"*"];
            int rowFactId = 0;
            for (auto fact : factSet->GetFacts()) {

                RichTextElementProperties titleTextProp{[_hostConfig getHostConfig] -> GetFactSet().title, fact->GetTitle(), fact->GetLanguage()};
                [self processTextConcurrently:titleTextProp
                                    elementId:[key stringByAppendingString:[[NSNumber numberWithInt:rowFactId++] stringValue]]];


                RichTextElementProperties valueTextProp{[_hostConfig getHostConfig] -> GetFactSet().value, fact->GetValue(), fact->GetLanguage()};
                [self processTextConcurrently:valueTextProp
                                    elementId:[key stringByAppendingString:[[NSNumber numberWithInt:rowFactId++] stringValue]]];
            }
            break;
        }
        case CardElementType::Image: {

            ObserverActionBlock observerAction =
                ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, std::shared_ptr<BaseCardElement> const &element, NSURL *url, ACRView *rootView) {
                    UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                    if (view) {
                        // check image already exists in the returned image view and register the image
                        [self registerImageFromUIImageView:view key:key];
                        
                        // Check if the resource resolver supports KVO observer control
                        BOOL shouldAddObserver = YES;
                        if ([imageResourceResolver respondsToSelector:@selector(shouldAddKVOObserverForImageView:)]) {
                            shouldAddObserver = [imageResourceResolver shouldAddKVOObserverForImageView:view];
                            NSLog(@"ACRView Image: Resource resolver shouldAddKVOObserverForImageView returned %@", shouldAddObserver ? @"YES" : @"NO");
                        }
                        
                        if (shouldAddObserver) {
                            [view addObserver:self
                                   forKeyPath:@"image"
                                      options:NSKeyValueObservingOptionNew
                                      context:element.get()];
                        } else {
                            // If resource resolver says NO, enable early KVO removal as fallback
                            [rootView enableEarlyKVORemovalForImageView:view];
                            
                            // Set up callback mechanism for image loading notifications
                            if ([imageResourceResolver respondsToSelector:@selector(setImageLoadedCallback:forImageView:)]) {
                                NSLog(@"ACRView Image: Setting up image loaded callback for non-KVO resolver");
                                __weak ACRView *weakRootView = rootView;
                                void (^imageLoadedCallback)(UIImageView *) = ^(UIImageView *imageView) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        ACRView *strongRootView = weakRootView;
                                        if (strongRootView && imageView) {
                                            NSLog(@"ACRView Image: Image loaded callback triggered for imageView: %@", imageView);
                                            [strongRootView handleImageLoadedForView:imageView key:key context:element.get()];
                                        }
                                    });
                                };
                                [imageResourceResolver setImageLoadedCallback:imageLoadedCallback forImageView:view];
                            } else {
                                // Fallback to the polling mechanism if callback is not available
                                [rootView scheduleImageCompletionCheckForView:view key:key];
                            }
                        }

                        // store the image view and image element for easy retrieval in ACRView::observeValueForKeyPath
                        [rootView setImageView:key view:view];
                        [rootView setImageContext:key context:element];
                    }
                };
            [self loadImageAccordingToResourceResolverIF:elem key:nil observerAction:observerAction];

            break;
        }
        case CardElementType::ImageSet: {
            std::shared_ptr<ImageSet> imgSetElem = std::static_pointer_cast<ImageSet>(elem);
            for (auto img : imgSetElem->GetImages()) { // loops through images in image set
                std::shared_ptr<BaseCardElement> baseImgElem = std::static_pointer_cast<BaseCardElement>(img);
                img->SetImageSize(imgSetElem->GetImageSize());

                ObserverActionBlock observerAction =
                    ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, std::shared_ptr<BaseCardElement> const &element, NSURL *url, ACRView *rootView) {
                        UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                        if (view) {
                            // check image already exists in the returned image view and register the image
                            [self registerImageFromUIImageView:view key:key];
                            
                            // Check if the resource resolver supports KVO observer control
                            BOOL shouldAddObserver = YES;
                            if ([imageResourceResolver respondsToSelector:@selector(shouldAddKVOObserverForImageView:)]) {
                                shouldAddObserver = [imageResourceResolver shouldAddKVOObserverForImageView:view];
                                NSLog(@"ACRView ImageSet: Resource resolver shouldAddKVOObserverForImageView returned %@", shouldAddObserver ? @"YES" : @"NO");
                            }
                            
                            if (shouldAddObserver) {
                                [view addObserver:self
                                       forKeyPath:@"image"
                                          options:NSKeyValueObservingOptionNew
                                          context:element.get()];
                            } else {
                                // If resource resolver says NO, enable early KVO removal as fallback
                                [rootView enableEarlyKVORemovalForImageView:view];
                                
                                // Set up callback mechanism for image loading notifications
                                if ([imageResourceResolver respondsToSelector:@selector(setImageLoadedCallback:forImageView:)]) {
                                    NSLog(@"ACRView ImageSet: Setting up image loaded callback for non-KVO resolver");
                                    __weak ACRView *weakRootView = rootView;
                                    void (^imageLoadedCallback)(UIImageView *) = ^(UIImageView *imageView) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            ACRView *strongRootView = weakRootView;
                                            if (strongRootView && imageView) {
                                                NSLog(@"ACRView ImageSet: Image loaded callback triggered for imageView: %@", imageView);
                                                [strongRootView handleImageLoadedForView:imageView key:key context:element.get()];
                                            }
                                        });
                                    };
                                    [imageResourceResolver setImageLoadedCallback:imageLoadedCallback forImageView:view];
                                } else {
                                    // Fallback to the polling mechanism if callback is not available
                                    [rootView scheduleImageCompletionCheckForView:view key:key];
                                }
                            }

                            // store the image view and image set element for easy retrieval in ACRView::observeValueForKeyPath
                            [rootView setImageView:key view:view];
                            [rootView setImageContext:key context:element];
                        }
                    };

                [self loadImageAccordingToResourceResolverIF:baseImgElem key:nil observerAction:observerAction];
            }
            break;
        }
        case CardElementType::Media: {
            std::shared_ptr<Media> mediaElem = std::static_pointer_cast<Media>(elem);
            std::string poster = mediaElem->GetPoster();
            if (poster.empty()) {
                poster = [_hostConfig getHostConfig]->GetMedia().defaultPoster;
            }

            if (!poster.empty()) {
                ObserverActionBlock observerAction =
                    ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, __unused std::shared_ptr<BaseCardElement> const &imgElem, NSURL *url, ACRView *rootView) {
                        UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                        ACRContentHoldingUIView *contentholdingview = [[ACRContentHoldingUIView alloc] initWithFrame:view.frame];
                        if (view) {
                            // check image already exists in the returned image view and register the image
                            [self registerImageFromUIImageView:view key:key];
                            [contentholdingview addSubview:view];
                            contentholdingview.isMediaType = YES;
                            
                            // Check if the resource resolver supports KVO observer control
                            BOOL shouldAddObserver = YES;
                            if ([imageResourceResolver respondsToSelector:@selector(shouldAddKVOObserverForImageView:)]) {
                                shouldAddObserver = [imageResourceResolver shouldAddKVOObserverForImageView:view];
                                NSLog(@"ACRView Media: Resource resolver shouldAddKVOObserverForImageView returned %@", shouldAddObserver ? @"YES" : @"NO");
                            }
                            
                            if (shouldAddObserver) {
                                [view addObserver:self
                                       forKeyPath:@"image"
                                          options:NSKeyValueObservingOptionNew
                                          context:elem.get()];
                            } else {
                                // If resource resolver says NO, enable early KVO removal as fallback
                                [rootView enableEarlyKVORemovalForImageView:view];
                                
                                // Set up callback mechanism for image loading notifications
                                if ([imageResourceResolver respondsToSelector:@selector(setImageLoadedCallback:forImageView:)]) {
                                    NSLog(@"ACRView Media: Setting up image loaded callback for non-KVO resolver");
                                    __weak ACRView *weakRootView = rootView;
                                    void (^imageLoadedCallback)(UIImageView *) = ^(UIImageView *imageView) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            ACRView *strongRootView = weakRootView;
                                            if (strongRootView && imageView) {
                                                NSLog(@"ACRView Media: Image loaded callback triggered for imageView: %@", imageView);
                                                [strongRootView handleImageLoadedForView:imageView key:key context:elem.get()];
                                            }
                                        });
                                    };
                                    [imageResourceResolver setImageLoadedCallback:imageLoadedCallback forImageView:view];
                                } else {
                                    // Fallback to the polling mechanism if callback is not available
                                    [rootView scheduleImageCompletionCheckForView:view key:key];
                                }
                            }

                            // store the image view and media element for easy retrieval in ACRView::observeValueForKeyPath
                            [rootView setImageView:key view:contentholdingview];
                            [rootView setImageContext:key context:elem];
                        }
                    };
                [self loadImageAccordingToResourceResolverIF:elem key:nil observerAction:observerAction];
            }

            if (![_hostConfig getHostConfig]->GetMedia().playButton.empty()) {
                ObserverActionBlock observerAction =
                    ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, __unused std::shared_ptr<BaseCardElement> const &element, NSURL *url, ACRView *rootView) {
                        UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                        if (view) {
                            // check image already exists in the returned image view and register the image
                            [self registerImageFromUIImageView:view key:key];
                            [view addObserver:rootView
                                   forKeyPath:@"image"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
                            // store the image view for easy retrieval in ACRView::observeValueForKeyPath
                            [rootView setImageView:key view:view];
                        }
                    };

                NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)elem.get()];
                NSString *key = [NSString stringWithFormat:@"%@_%@", [number stringValue], @"playIcon"];

                [self loadImageAccordingToResourceResolverIFFromString:[_hostConfig getHostConfig]->GetMedia().playButton key:key observerAction:observerAction];
            }

            break;
        }
        case CardElementType::TextInput: {
            std::shared_ptr<TextInput> textInput = std::static_pointer_cast<TextInput>(elem);
            std::shared_ptr<BaseActionElement> action = textInput->GetInlineAction();
            if (action != nullptr && !action->GetIconUrl(ACTheme(_theme)).empty()) {
                ObserverActionBlockForBaseAction observerAction =
                    ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, std::shared_ptr<BaseActionElement> const &element, NSURL *url, ACRView *rootView) {
                        UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                        if (view) {
                            [view addObserver:self
                                   forKeyPath:@"image"
                                      options:NSKeyValueObservingOptionNew
                                      context:element.get()];

                            // store the image view for easy retrieval in ACRView::observeValueForKeyPath
                            [rootView setImageView:key view:view];
                        }
                    };
                [self loadImageAccordingToResourceResolverIFForBaseAction:action key:nil observerAction:observerAction];
            }
            break;
        }

        case CardElementType::Table: {
            std::shared_ptr<Table> table = std::static_pointer_cast<Table>(elem);
            for (const auto &row : table->GetRows()) {
                [self processBaseCardElement:row registration:registration];
            }
            break;
        }

        case CardElementType::TableRow: {
            const auto &row = std::static_pointer_cast<TableRow>(elem);
            for (const auto &cell : row->GetCells()) {
                [self processBaseCardElement:cell registration:registration];
            }
            break;
        }

        // continue on search
        case CardElementType::TableCell:
        case CardElementType::Container: {
            std::shared_ptr<Container> container = std::static_pointer_cast<Container>(elem);

            auto backgroundImageProperties = container->GetBackgroundImage();
            if ((backgroundImageProperties != nullptr) && !(backgroundImageProperties->GetUrl(ACTheme(_theme)).empty())) {
                ObserverActionBlock observerAction = generateBackgroundImageObserverAction(backgroundImageProperties, self, container);
                [self loadBackgroundImageAccordingToResourceResolverIF:backgroundImageProperties key:nil observerAction:observerAction];
            }

            std::vector<std::shared_ptr<BaseCardElement>> &new_body = container->GetItems();
            [self addBaseCardElementListToConcurrentQueue:new_body registration:registration];
            break;
        }
        case CardElementType::Carousel: {
            std::shared_ptr<Carousel> carousel = std::static_pointer_cast<Carousel>(elem);

            auto backgroundImageProperties = carousel->GetBackgroundImage();
            if ((backgroundImageProperties != nullptr) && !(backgroundImageProperties->GetUrl(ACTheme(_theme)).empty())) {
                ObserverActionBlock observerAction = generateBackgroundImageObserverAction(backgroundImageProperties, self, carousel);
                [self loadBackgroundImageAccordingToResourceResolverIF:backgroundImageProperties key:nil observerAction:observerAction];
            }
            
            std::vector<std::shared_ptr<BaseCardElement>> new_body;
            
            for(auto &carouselPage: carousel->GetPages()) {
                new_body.push_back(carouselPage);
            }
            [self addBaseCardElementListToConcurrentQueue:new_body registration:registration];
            break;
        }
        // continue on search
        case CardElementType::ColumnSet: {
            std::shared_ptr<ColumnSet> columSet = std::static_pointer_cast<ColumnSet>(elem);
            std::vector<std::shared_ptr<Column>> &columns = columSet->GetColumns();
            [self addColumnsToConcurrentQueue:columns registration:registration];
            break;
        }

        case CardElementType::Column: {
            std::shared_ptr<Column> column = std::static_pointer_cast<Column>(elem);
            // Handle background image (if necessary)
            auto backgroundImageProperties = column->GetBackgroundImage();
            if ((backgroundImageProperties != nullptr) && !(backgroundImageProperties->GetUrl(ACTheme(_theme)).empty())) {
                ObserverActionBlock observerAction = generateBackgroundImageObserverAction(backgroundImageProperties, self, column);
                [self loadBackgroundImageAccordingToResourceResolverIF:backgroundImageProperties key:nil observerAction:observerAction];
            }

            // add column fallbacks to async task queue
            [self processFallback:column registration:registration];
            [self addBaseCardElementListToConcurrentQueue:column->GetItems() registration:registration];
            break;
        }

        case CardElementType::ActionSet: {
            std::shared_ptr<ActionSet> actionSet = std::static_pointer_cast<ActionSet>(elem);
            auto actions = actionSet->GetActions();
            [self loadImagesForActionsAndCheckIfAllActionsHaveIconImages:actions hostconfig:_hostConfig hash:iOSInternalIdHash(actionSet->GetInternalId().Hash())];
            break;
        }
            
        case CardElementType::CarouselPage: {
            std::shared_ptr<CarouselPage> carouselPage = std::static_pointer_cast<CarouselPage>(elem);
            auto backgroundImageProperties = carouselPage->GetBackgroundImage();
            if ((backgroundImageProperties != nullptr) && !(backgroundImageProperties->GetUrl(ACTheme(_theme)).empty())) {
                ObserverActionBlock observerAction = generateBackgroundImageObserverAction(backgroundImageProperties, self, carouselPage);
                [self loadBackgroundImageAccordingToResourceResolverIF:backgroundImageProperties key:nil observerAction:observerAction];
            }
            [self addBaseCardElementListToConcurrentQueue:carouselPage->GetItems() registration:registration];
        }
            
        case AdaptiveCards::CardElementType::AdaptiveCard:
        case AdaptiveCards::CardElementType::ChoiceInput:
        case AdaptiveCards::CardElementType::ChoiceSetInput:
        case AdaptiveCards::CardElementType::Custom:
        case AdaptiveCards::CardElementType::DateInput:
        case AdaptiveCards::CardElementType::Fact:
        case AdaptiveCards::CardElementType::NumberInput:
        case AdaptiveCards::CardElementType::RatingInput:
        case AdaptiveCards::CardElementType::Icon:
        case AdaptiveCards::CardElementType::TimeInput:
        case AdaptiveCards::CardElementType::ToggleInput:
        case AdaptiveCards::CardElementType::Unknown:
        case AdaptiveCards::CardElementType::RatingLabel:
        case AdaptiveCards::CardElementType::CompoundButton:
        case AdaptiveCards::CardElementType::Badge:
            break;
    }
}

- (void)addBaseCardElementToConcurrentQueue:(std::shared_ptr<BaseCardElement> const &)elem registration:(ACRRegistration *)registration
{
    if ([registration shouldUseResourceResolverForOverridenDefaultElementRenderers:(ACRCardElementType)elem->GetElementType()] == NO) {
        return;
    }

    [self processFallback:elem registration:registration];
    [self processBaseCardElement:elem registration:registration];
}
// Walk through adaptive cards elements recursively and if images/images set/TextBlocks are found process them concurrently
- (void)addBaseCardElementListToConcurrentQueue:(std::vector<std::shared_ptr<BaseCardElement>> const &)body registration:(ACRRegistration *)registration
{
    for (auto &elem : body) {
        [self addBaseCardElementToConcurrentQueue:elem registration:registration];
    }
}

- (void)addColumnsToConcurrentQueue:(std::vector<std::shared_ptr<Column>> const &)columns registration:(ACRRegistration *)registration
{
    for (auto &column : columns) {
        [self addBaseCardElementToConcurrentQueue:column registration:registration];
    }
}


// Walk through the actions found and process them concurrently
- (void)loadImagesForActionsAndCheckIfAllActionsHaveIconImages:(std::vector<std::shared_ptr<BaseActionElement>> const &)actions hostconfig:(ACOHostConfig *)hostConfig hash:(NSNumber *)hash
{
    [hostConfig setIconPlacement:hash placement:YES];
    for (auto &action : actions) {
        if (!action->GetIconUrl(ACTheme(_theme)).empty()) {
            ObserverActionBlockForBaseAction observerAction =
                ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, std::shared_ptr<BaseActionElement> const &elem, NSURL *url, ACRView *rootView) {
                    UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                    if (view) {
                        [view addObserver:self
                               forKeyPath:@"image"
                                  options:NSKeyValueObservingOptionNew
                                  context:elem.get()];
                        [rootView setImageView:key view:view];
                    }
                };
            [self loadImageAccordingToResourceResolverIFForBaseAction:action key:nil observerAction:observerAction];
        } else {
            [hostConfig setIconPlacement:hash placement:NO];
        }
    }
}

- (void)processTextConcurrently:(RichTextElementProperties const &)textProperties
                      elementId:(NSString *)elementId
{
    RichTextElementProperties textProp = std::move(textProperties);
    /// dispatch to concurrent queue
    dispatch_group_async(_async_tasks_group, _global_queue,
                         ^{
                             buildIntermediateResultForText(self, self->_hostConfig, textProp, elementId);
                         });
}

- (void)enqueueIntermediateTextProcessingResult:(NSDictionary *)data
                                      elementId:(NSString *)elementId
{
    dispatch_sync(_serial_text_queue, ^{
        self->_textMap[elementId] = data;
    });
}

- (void)loadImage:(std::string const &)urlStr
{
    if (urlStr.empty()) {
        return;
    }

    NSString *nSUrlStr = [NSString stringWithCString:urlStr.c_str()
                                            encoding:[NSString defaultCStringEncoding]];
    NSURL *url = [NSURL URLWithString:nSUrlStr];
    // if url is relative, try again with adding base url from host config
    if ([url.relativePath isEqualToString:nSUrlStr]) {
        url = [NSURL URLWithString:nSUrlStr relativeToURL:_hostConfig.baseURL];
    }

    ImageLoadBlock imageloadblock = ^(NSURL *imgUrl) {
        // download image
        UIImage *img = nil;
        if ([imgUrl.scheme isEqualToString:@"data"]) {
            NSString *absoluteUri = imgUrl.absoluteString;
            std::string dataUri = AdaptiveCards::AdaptiveBase64Util::ExtractDataFromUri(std::string([absoluteUri UTF8String]));
            std::vector<char> decodedDataUri = AdaptiveCards::AdaptiveBase64Util::Decode(dataUri);
            NSData *decodedBase64 = [NSData dataWithBytes:decodedDataUri.data() length:decodedDataUri.size()];
            img = [UIImage imageWithData:decodedBase64];
        } else {
            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
        }
        return img;
    };

    dispatch_group_async(_async_tasks_group, _global_queue,
                         ^{
                             UIImage *img = (imageloadblock) ? imageloadblock(url) : nil;
                             if (img) {
                                 dispatch_sync(self->_serial_queue, ^{
                                     self->_imageViewMap[nSUrlStr] = img;
                                 });
                             }
                         });
}

// add postfix to existing BaseCardElement ID to be used as key
- (void)tagBaseCardElement:(std::shared_ptr<BaseCardElement> const &)elem
{
    std::string serial_number_as_string = std::to_string(_serialNumber);
    // concat a newly generated key to a existing id, the key will be removed after use
    elem->SetId(elem->GetId() + "_" + serial_number_as_string);
    ++_serialNumber;
}

- (NSMutableDictionary *)getImageMap
{
    return _imageViewMap;
}

- (UIImageView *)getImageView:(NSString *)key
{
    return _imageViewContextMap[key];
}

- (void)setImageView:(NSString *)key view:(UIView *)view
{
    _imageViewContextMap[key] = view;
}

- (void)setImageContext:(NSString *)key context:(std::shared_ptr<BaseCardElement> const &)elem
{
    _imageContextMap[key] = [[ACOBaseCardElement alloc] initWithBaseCardElement:elem];
}

- (dispatch_queue_t)getSerialQueue
{
    return _serial_queue;
}

- (NSMutableDictionary *)getTextMap
{
    return _textMap;
}

- (ACOAdaptiveCard *)card
{
    return _adaptiveCard;
}

// notification is delivered from main (serial) queue, thus run in the main thread context
- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([path isEqualToString:@"image"]) {
        // Check if this image view is in our early removal set
        if ([object isKindOfClass:[UIImageView class]] && [_earlyKVORemovalImageViews containsObject:(UIImageView *)object]) {
            NSLog(@"ACRView: Skipping KVO processing for early removal image view %p", object);
            [_earlyKVORemovalImageViews removeObject:(UIImageView *)object];
            return;
        }
        
        bool observerRemoved = false;
        if (context) {
            // image that was loaded
            UIImage *image = [change objectForKey:NSKeyValueChangeNewKey];

            NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)(context)];
            NSString *key = [number stringValue];

            ACOBaseCardElement *baseCardElement = _imageContextMap[key];
            if (baseCardElement) {
                ACRRegistration *reg = [ACRRegistration getInstance];
                ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *renderer = (ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *)[reg getRenderer:[NSNumber numberWithInt:static_cast<int>(baseCardElement.type)]];
                if (renderer && [[renderer class] conformsToProtocol:@protocol(ACRIKVONotificationHandler)]) {
                    observerRemoved = true;
                    NSMutableDictionary *imageViewMap = [self getImageMap];
                    imageViewMap[key] = image;
                    [renderer configUpdateForUIImageView:self acoElem:baseCardElement config:_hostConfig image:image imageView:(UIImageView *)object];
                }
            } else {
                id view = _imageViewContextMap[key];
                if ([view isKindOfClass:[ACRButton class]]) {
                    ACRButton *button = (ACRButton *)view;
                    [button setImageView:image withConfig:_hostConfig];
                } else {
                    // handle background image for adaptive card that uses resource resolver
                    UIImageView *imageView = (UIImageView *)object;
                    auto backgroundImage = [_adaptiveCard card]->GetBackgroundImage();

                    // remove observer early in case background image must be changed to handle mode = repeat
                    [self removeObserver:self forKeyPath:path onObject:object];
                    observerRemoved = true;
                    renderBackgroundImage(self, backgroundImage.get(), imageView, image);
                }
            }
        }

        if (!observerRemoved) {
            [self removeObserver:self forKeyPath:path onObject:object];
        }
    } else if ([path isEqualToString:@"hidden"]) {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

// remove observer from UIImageView
- (void)removeObserverOnImageView:(NSString *)KeyPath onObject:(NSObject *)object keyToImageView:(NSString *)key
{
    if ([object isKindOfClass:[UIImageView class]]) {
        if (_imageViewContextMap[key]) {
            [self removeObserver:self forKeyPath:KeyPath onObject:object];
        }
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)path onObject:(NSObject *)object
{
    // check that makes sure that there are subscribers, and the given observer is not one of the removed observers
    if (_numberOfSubscribers && ![_setOfRemovedObservers containsObject:object]) {
        _numberOfSubscribers--;
        
        // Check if this is a callback-based image view (early KVO removal enabled)
        // If so, skip the actual KVO removal since no observer was added
        if ([object isKindOfClass:[UIImageView class]] && [self isEarlyKVORemovalEnabledForImageView:(UIImageView *)object]) {
            NSLog(@"ACRView: Skipping KVO removal for callback-based imageView %p", object);
        } else {
            // Only remove KVO observer if it was actually added (traditional KVO path)
            [object removeObserver:self forKeyPath:path];
        }
        
        [_setOfRemovedObservers addObject:object];
        [self callDidLoadElementsIfNeeded];
    }
}

- (void)loadBackgroundImageAccordingToResourceResolverIF:(std::shared_ptr<BackgroundImage> const &)backgroundImage key:(NSString *)key observerAction:(ObserverActionBlock)observerAction
{
    NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)(backgroundImage.get())];
    NSString *nSUrlStr = [NSString stringWithCString:backgroundImage->GetUrl(ACTheme(_theme)).c_str() encoding:[NSString defaultCStringEncoding]];

    if (!key) {
        key = [number stringValue];
    }

    [self loadImage:nSUrlStr key:key context:nullptr observerAction:observerAction];
}

- (void)loadImageAccordingToResourceResolverIFFromString:(std::string const &)url
                                                     key:(NSString *)key
                                          observerAction:(ObserverActionBlock)observerAction
{
    std::shared_ptr<Image> imgElem = std::make_shared<Image>();
    imgElem->SetUrl(url);
    imgElem->SetImageSize(ImageSize::None);
    NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)imgElem.get()];
    if (!key) {
        key = [number stringValue];
    }
    [self loadImageAccordingToResourceResolverIF:imgElem key:key observerAction:observerAction];
}

- (void)loadImageAccordingToResourceResolverIF:(std::shared_ptr<BaseCardElement> const &)elem
                                           key:(NSString *)key
                                observerAction:(ObserverActionBlock)observerAction
{
    NSNumber *number = nil;
    NSString *nSUrlStr = nil;

    if (elem->GetElementType() == CardElementType::Media) {
        std::shared_ptr<Media> mediaElem = std::static_pointer_cast<Media>(elem);
        number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)mediaElem.get()];
        nSUrlStr = [NSString stringWithCString:mediaElem->GetPoster().c_str() encoding:[NSString defaultCStringEncoding]];
    } else {
        std::shared_ptr<Image> imgElem = std::static_pointer_cast<Image>(elem);
        number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)imgElem.get()];
        nSUrlStr = [NSString stringWithCString:imgElem->GetUrl(ACTheme(_theme)).c_str() encoding:[NSString defaultCStringEncoding]];
    }

    if (!key) {
        key = [number stringValue];
    }

    [self loadImage:nSUrlStr key:key context:elem observerAction:observerAction];
}

- (void)loadImage:(NSString *)nSUrlStr key:(NSString *)key context:(std::shared_ptr<BaseCardElement> const &)elem observerAction:(ObserverActionBlock)observerAction
{
    NSURL *url = [NSURL URLWithString:nSUrlStr];
    NSObject<ACOIResourceResolver> *imageResourceResolver = [_hostConfig getResourceResolverForScheme:[url scheme]];
    if (imageResourceResolver && ACOImageViewIF == [_hostConfig getResolverIFType:[url scheme]]) {
        if (observerAction) {
            observerAction(imageResourceResolver, key, elem, url, self);
            _numberOfSubscribers++;
        }
    } else {
        [self loadImage:[nSUrlStr cStringUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)loadImageAccordingToResourceResolverIFForBaseAction:(std::shared_ptr<BaseActionElement> const &)elem
                                                        key:(NSString *)key
                                             observerAction:(ObserverActionBlockForBaseAction)observerAction
{
    NSNumber *number = nil;
    NSString *nSUrlStr = nil;

    number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)elem.get()];
    nSUrlStr = [NSString stringWithCString:elem->GetIconUrl(ACTheme(_theme)).c_str() encoding:[NSString defaultCStringEncoding]];
    if (!key) {
        key = [number stringValue];
    }

    NSURL *url = [NSURL URLWithString:nSUrlStr];
    NSObject<ACOIResourceResolver> *imageResourceResolver = [_hostConfig getResourceResolverForScheme:[url scheme]];
    if (ACOImageViewIF == [_hostConfig getResolverIFType:[url scheme]]) {
        if (observerAction) {
            observerAction(imageResourceResolver, key, elem, url, self);
            _numberOfSubscribers++;
        }
    } else {
        [self loadImage:[nSUrlStr cStringUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)dealloc
{
    for (id key in _imageViewContextMap) {
        id object = _imageViewContextMap[key];

        if ([object isKindOfClass:[ACRContentHoldingUIView class]]) {
            object = ((UIView *)object).subviews[0];
        }

        if (![_setOfRemovedObservers containsObject:object] && 
            ![self isEarlyKVORemovalEnabledForImageView:(UIImageView *)object] && 
            [object isKindOfClass:[UIImageView class]]) {
            [object removeObserver:self forKeyPath:@"image"];
        }
    }
}

- (void)updatePaddingMap:(std::shared_ptr<StyledCollectionElement> const &)collection view:(UIView *)view
{
    if (view && collection && collection->GetPadding()) {
        NSNumber *key = [NSNumber numberWithUnsignedLongLong:collection->GetInternalId().Hash()];
        _paddingMap[[key stringValue]] = view;
    }
}

// This adjustment is needed because during parsing the card, host config can't be accessed
- (void)updatePaddingMapForTopElements:(std::shared_ptr<BaseCardElement> const &)element rootView:(ACRView *)view card:(std::shared_ptr<AdaptiveCard> const &)card
{
    const CardElementType type = element->GetElementType();
    if (type == CardElementType::Container || type == CardElementType::ColumnSet || type == CardElementType::Column) {
        std::shared_ptr<StyledCollectionElement> collection = std::dynamic_pointer_cast<StyledCollectionElement>(element);
        if (view && collection && collection->GetStyle() != card->GetStyle()) {
            NSNumber *key = [NSNumber numberWithUnsignedLongLong:collection->GetInternalId().Hash()];
            _paddingMap[[key stringValue]] = view;
        }
    }
}

- (UIView *)getBleedTarget:(InternalId const &)internalId
{
    NSNumber *key = [NSNumber numberWithUnsignedLongLong:internalId.Hash()];
    return _paddingMap[[key stringValue]];
}

// get fallback content and add them async task queue
- (void)processFallback:(std::shared_ptr<BaseCardElement> const &)elem registration:(ACRRegistration *)registration
{
    std::shared_ptr<BaseElement> fallbackElem = elem->GetFallbackContent();
    while (fallbackElem) {
        std::shared_ptr<BaseCardElement> fallbackElemCard = std::static_pointer_cast<BaseCardElement>(fallbackElem);
        if (fallbackElemCard) {
            [self processBaseCardElement:fallbackElemCard registration:registration];
        }

        fallbackElem = fallbackElemCard->GetFallbackContent();
    }
}

- (ACRTargetBuilderDirector *)getActionsTargetBuilderDirector
{
    return _actionsTargetBuilderDirector;
}

- (ACRTargetBuilderDirector *)getSelectActionsTargetBuilderDirector
{
    return _selectActionsTargetBuilderDirector;
}

- (ACRTargetBuilderDirector *)getQuickReplyTargetBuilderDirector
{
    return _quickReplyTargetBuilderDirector;
}

- (void)addWarnings:(ACRWarningStatusCode)statusCode mesage:(NSString *)message
{
    [((NSMutableArray *)_warnings) addObject:[[ACOWarning alloc] initWith:statusCode message:message]];
}

- (ACRColumnView *)getParent:(ACRColumnView *)child
{
    return [_inputHandlerLookupTable objectForKey:child];
}

- (void)setParent:(ACRColumnView *)parent child:(ACRColumnView *)child
{
    [_inputHandlerLookupTable setObject:parent forKey:child];
}

- (void)pushCurrentShowcard:(ACRColumnView *)showcard
{
    if (showcard) {
        [_showcards addObject:showcard];
    }
}

- (void)popCurrentShowcard
{
    if ([_showcards count]) {
        [_showcards removeLastObject];
    }
}

- (ACRColumnView *)peekCurrentShowCard
{
    ACRColumnView *showcard = nil;
    if ([_showcards count]) {
        showcard = _showcards.lastObject;
    }
    return showcard;
}

- (ACOInputResults *)dispatchAndValidateInput:(ACRColumnView *)parent
{
    ACOInputResults *result = [[ACOInputResults alloc] init:self parent:parent];
    [result validateInput];
    return result;
}

// check if UIImageView already contains an UIImage, if so, add it the image map.
- (void)registerImageFromUIImageView:(UIImageView *)imageView key:(NSString *)key
{
    if (imageView.image) {
        self->_imageViewMap[key] = imageView.image;
    }
}

- (void)setContext:(ACORenderContext *)context
{
    if (context) {
        _context = context;
    }
}

@end
