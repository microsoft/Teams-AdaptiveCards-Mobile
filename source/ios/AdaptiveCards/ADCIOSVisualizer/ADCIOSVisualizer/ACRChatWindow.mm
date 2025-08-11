//
//  ACRChatWindow.mm
//  ACRChatWindow
//
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "ACRChatWindow.h"
#import "ADCResolver.h"
#import "ADCResolver.h"
#import "ADCKVOTestResolver.h"
#import <AdaptiveCards/ACOResourceResolvers.h>
#import <Foundation/Foundation.h>

// MARK: - MockSwiftKVOManager Implementation
// Implementation moved here to ensure it's compiled with the visualizer target

@interface MockSwiftKVOManager()
@property (nonatomic, strong) NSHashTable<UIView *> *observedViews;
@end

@implementation MockSwiftKVOManager

+ (instancetype)shared {
    static MockSwiftKVOManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.observedViews = [NSHashTable weakObjectsHashTable];
    });
    return sharedInstance;
}

- (NSUInteger)observerCount {
    return self.observedViews.count;
}

- (void)addImageObserver:(UIView *)view {
    if (!view) {
        NSLog(@"⚠️ MockSwiftKVOManager: Cannot add observer for nil view");
        return;
    }
    
    [self.observedViews addObject:view];
    NSLog(@"🔗 MockSwiftKVOManager: Added image observer for view: %@", NSStringFromClass([view class]));
    NSLog(@"📊 MockSwiftKVOManager: Total observers: %lu", (unsigned long)self.observedViews.count);
    
    // Find UIImageView within the composite view for KVO
    UIImageView *targetImageView = [self findImageViewInView:view];
    if (targetImageView) {
        NSLog(@"✅ MockSwiftKVOManager: Found UIImageView in composite view, setting up KVO");
        [self setupKVOForImageView:targetImageView];
    } else {
        NSLog(@"⚠️ MockSwiftKVOManager: No UIImageView found in view hierarchy");
    }
}

- (void)removeImageObserver:(UIView *)view {
    if (!view) return;
    
    // Find and clean up KVO for UIImageView
    UIImageView *targetImageView = [self findImageViewInView:view];
    if (targetImageView) {
        [self cleanupKVOForImageView:targetImageView];
    }
    
    [self.observedViews removeObject:view];
    NSLog(@"🔗 MockSwiftKVOManager: Removed image observer for view: %@", NSStringFromClass([view class]));
    NSLog(@"📊 MockSwiftKVOManager: Total observers: %lu", (unsigned long)self.observedViews.count);
}

- (void)setupKVOForImageView:(UIImageView *)imageView {
    if (!imageView) return;
    
    NSLog(@"🎯 MockSwiftKVOManager: Setting up KVO for UIImageView: %@", imageView);
    
    // Add KVO observer for image property
    @try {
        [imageView addObserver:self
                    forKeyPath:@"image"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:(__bridge void *)(imageView)];
        NSLog(@"✅ MockSwiftKVOManager: KVO observer added successfully");
    } @catch (NSException *exception) {
        NSLog(@"❌ MockSwiftKVOManager: Failed to add KVO observer: %@", exception.reason);
    }
}

- (void)cleanupKVOForImageView:(UIImageView *)imageView {
    if (!imageView) return;
    
    NSLog(@"🧹 MockSwiftKVOManager: Cleaning up KVO for UIImageView: %@", imageView);
    
    @try {
        [imageView removeObserver:self forKeyPath:@"image" context:(__bridge void *)(imageView)];
        NSLog(@"✅ MockSwiftKVOManager: KVO observer removed successfully");
    } @catch (NSException *exception) {
        NSLog(@"⚠️ MockSwiftKVOManager: Exception during KVO cleanup (may be already removed): %@", exception.reason);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"image"] && [object isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)object;
        
        // Safely extract image values - KVO can return NSNull for nil values
        id newImageValue = change[NSKeyValueChangeNewKey];
        id oldImageValue = change[NSKeyValueChangeOldKey];
        
        UIImage *newImage = ([newImageValue isKindOfClass:[UIImage class]]) ? newImageValue : nil;
        UIImage *oldImage = ([oldImageValue isKindOfClass:[UIImage class]]) ? oldImageValue : nil;
        
        NSLog(@"🔄 MockSwiftKVOManager: Image changed for UIImageView");
        NSLog(@"   - Old image: %@", oldImage ? [NSString stringWithFormat:@"%.0fx%.0f", oldImage.size.width, oldImage.size.height] : @"nil");
        NSLog(@"   - New image: %@", newImage ? [NSString stringWithFormat:@"%.0fx%.0f", newImage.size.width, newImage.size.height] : @"nil");
        
        // Find the parent composite view
        UIView *compositeView = [self findCompositeViewForImageView:imageView];
        if (compositeView) {
            [self processImageChange:compositeView image:newImage];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)processImageChange:(UIView *)compositeView image:(UIImage *)image {
    NSLog(@"📸 MockSwiftKVOManager: Processing image change for composite view: %@", NSStringFromClass([compositeView class]));
    
    if (image) {
        NSLog(@"✅ MockSwiftKVOManager: Image loaded successfully - size: %.2f x %.2f", image.size.width, image.size.height);
        
        // Trigger layout update for the composite view
        dispatch_async(dispatch_get_main_queue(), ^{
            [compositeView setNeedsLayout];
            [compositeView layoutIfNeeded];
            NSLog(@"🔄 MockSwiftKVOManager: Layout update triggered for composite view");
        });
    } else {
        NSLog(@"⚠️ MockSwiftKVOManager: Image is nil");
    }
}

- (UIImageView *)findImageViewInView:(UIView *)view {
    if ([view isKindOfClass:[UIImageView class]]) {
        NSLog(@"🎯 MockSwiftKVOManager: Found UIImageView: %@", view);
        return (UIImageView *)view;
    }
    
    // Recursively search subviews
    for (UIView *subview in view.subviews) {
        UIImageView *result = [self findImageViewInView:subview];
        if (result) {
            NSLog(@"🎯 MockSwiftKVOManager: Found UIImageView in subview hierarchy: %@", result);
            return result;
        }
    }
    
    return nil;
}

- (UIView *)findCompositeViewForImageView:(UIImageView *)imageView {
    UIView *currentView = imageView.superview;
    
    // Walk up the view hierarchy looking for our composite view
    while (currentView) {
        if ([NSStringFromClass([currentView class]) containsString:@"TestCompositeImageView"]) {
            NSLog(@"🎯 MockSwiftKVOManager: Found composite view: %@", NSStringFromClass([currentView class]));
            return currentView;
        }
        currentView = currentView.superview;
    }
    
    NSLog(@"⚠️ MockSwiftKVOManager: No composite view found for UIImageView");
    return nil;
}

@end

// MARK: - TestCompositeImageView Implementation
// Implementation moved here to ensure it's compiled with the visualizer target

@interface TestCompositeImageView()
@property (nonatomic, strong, readwrite) UIImageView *internalImageView;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *imageViewConstraints;
@end

@implementation TestCompositeImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInternalImageView];
        [self setupConstraints];
        
        // Add some visual distinction for testing
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor blueColor].CGColor;
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:1.0]; // Light blue tint
        
        NSLog(@"🧪 TestCompositeImageView: Initialized with frame: %@", NSStringFromCGRect(frame));
    }
    return self;
}

- (void)setupInternalImageView {
    _internalImageView = [[UIImageView alloc] init];
    _internalImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _internalImageView.contentMode = UIViewContentModeScaleAspectFit;
    _internalImageView.clipsToBounds = YES;
    
    // Add distinctive styling to the internal image view
    _internalImageView.layer.borderWidth = 1.0;
    _internalImageView.layer.borderColor = [UIColor greenColor].CGColor;
    
    [self addSubview:_internalImageView];
    NSLog(@"🧪 TestCompositeImageView: Created internal UIImageView");
}

- (void)setupConstraints {
    // Pin internal imageView to edges with some padding
    _imageViewConstraints = @[
        [_internalImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [_internalImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [_internalImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
        [_internalImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8]
    ];
    
    [NSLayoutConstraint activateConstraints:_imageViewConstraints];
    NSLog(@"🧪 TestCompositeImageView: Setup constraints for internal imageView");
}

- (void)setImageFromURL:(NSURL *)url {
    NSLog(@"🧪 TestCompositeImageView: Loading image from URL: %@", url.absoluteString);
    
    // Register with MockSwiftKVOManager for external KVO management
    [[MockSwiftKVOManager shared] addImageObserver:self];
    
    // Simulate async image loading
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                NSLog(@"🧪 TestCompositeImageView: Successfully loaded image with size: %.2f x %.2f", image.size.width, image.size.height);
                self.internalImageView.image = image;
                
                // Force layout update
                [self setNeedsLayout];
                [self layoutIfNeeded];
            } else {
                NSLog(@"🧪 TestCompositeImageView: Failed to load image from URL");
                // Set a placeholder image for testing
                self.internalImageView.image = [self createPlaceholderImage];
            }
        });
    });
}

- (UIImage *)createPlaceholderImage {
    CGSize size = CGSizeMake(100, 100);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // Draw a simple placeholder
    [[UIColor lightGrayColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    
    [[UIColor darkGrayColor] setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(10, 10, size.width-20, size.height-20)];
    path.lineWidth = 2.0;
    [path stroke];
    
    // Add "TEST" text
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
        NSForegroundColorAttributeName: [UIColor darkGrayColor]
    };
    [@"TEST" drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"🧪 TestCompositeImageView: Created placeholder image");
    return image;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.internalImageView.layer.cornerRadius = cornerRadius > 0 ? cornerRadius - 2 : 0; // Slightly smaller radius for internal view
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"🧪 TestCompositeImageView: layoutSubviews called - frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"🧪 TestCompositeImageView: Internal imageView frame: %@", NSStringFromCGRect(self.internalImageView.frame));
}

- (CGSize)intrinsicContentSize {
    if (self.internalImageView.image) {
        CGSize imageSize = self.internalImageView.image.size;
        // Add padding to the intrinsic size
        CGSize intrinsicSize = CGSizeMake(imageSize.width + 16, imageSize.height + 16);
        NSLog(@"🧪 TestCompositeImageView: intrinsicContentSize: %@", NSStringFromCGSize(intrinsicSize));
        return intrinsicSize;
    }
    
    // Default size when no image
    CGSize defaultSize = CGSizeMake(120, 120);
    NSLog(@"🧪 TestCompositeImageView: intrinsicContentSize (default): %@", NSStringFromCGSize(defaultSize));
    return defaultSize;
}

- (void)dealloc {
    // Clean up KVO observer
    [[MockSwiftKVOManager shared] removeImageObserver:self];
    NSLog(@"🧪 TestCompositeImageView: dealloc - cleaned up KVO observer");
}

@end

// MARK: - TestGenericViewImageResolver Implementation
// Implementation moved here to ensure it's compiled with the visualizer target

@implementation TestGenericViewImageResolver

+ (instancetype)sharedResolver {
    static TestGenericViewImageResolver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        // Default configuration for testing
        sharedInstance.useGenericViewResolution = YES;
        sharedInstance.enableExternalKVO = YES;
    });
    return sharedInstance;
}

// Traditional UIImageView resolution (fallback)
- (UIImageView *)resolveImageViewResource:(NSURL *)url {
    NSLog(@"🔄 TestGenericViewImageResolver: resolveImageViewResource called for URL: %@", url.absoluteString);
    
    if (self.useGenericViewResolution) {
        NSLog(@"⚠️ TestGenericViewImageResolver: Generic resolution enabled, this fallback shouldn't be called");
    }
    
    // Create standard UIImageView and load image
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                NSLog(@"🔄 TestGenericViewImageResolver: Traditional resolution completed for %@", url.absoluteString);
            });
        }
    });
    
    return imageView;
}

// GENERIC VIEW RESOLUTION - Primary method for composite views
- (UIView *)resolveImageViewAsGenericView:(NSURL *)url {
    NSLog(@"🚀 TestGenericViewImageResolver: resolveImageViewAsGenericView called for URL: %@", url.absoluteString);
    
    if (!self.useGenericViewResolution) {
        NSLog(@"⚠️ TestGenericViewImageResolver: Generic resolution disabled, returning nil");
        return nil;
    }
    
    // Create composite view that simulates TeamsUI ImageView structure
    TestCompositeImageView *compositeView = [[TestCompositeImageView alloc] init];
    [compositeView setImageFromURL:url];
    NSLog(@"✅ TestGenericViewImageResolver: Created TestCompositeImageView for %@", url.absoluteString);
    
    // Add external KVO management if enabled
    if (self.enableExternalKVO) {
        NSLog(@"🔗 TestGenericViewImageResolver: Enabling external KVO management for composite view");
        [[MockSwiftKVOManager shared] addImageObserver:compositeView];
    }
    
    return compositeView;
}

// Generic background image resolution
- (UIView *)resolveBackgroundImageViewAsGenericView:(NSURL *)url hasStretch:(BOOL)hasStretch {
    NSLog(@"🌄 TestGenericViewImageResolver: resolveBackgroundImageViewAsGenericView called for URL: %@", url.absoluteString);
    
    if (!self.useGenericViewResolution) {
        NSLog(@"⚠️ TestGenericViewImageResolver: Generic background resolution disabled, returning nil");
        return nil;
    }
    
    // Create composite view for background (same structure as regular images)
    TestCompositeImageView *backgroundView = [[TestCompositeImageView alloc] init];
    [backgroundView setImageFromURL:url];
    
    // Apply stretch configuration if needed
    if (hasStretch) {
        backgroundView.internalImageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    NSLog(@"✅ TestGenericViewImageResolver: Created background TestCompositeImageView for %@", url.absoluteString);
    
    // Add external KVO management if enabled
    if (self.enableExternalKVO) {
        NSLog(@"🔗 TestGenericViewImageResolver: Enabling external KVO management for background composite view");
        [[MockSwiftKVOManager shared] addImageObserver:backgroundView];
    }
    
    return backgroundView;
}

// Traditional background resolution (fallback)
- (UIImageView *)resolveBackgroundImageViewResource:(NSURL *)url hasStretch:(BOOL)hasStretch {
    NSLog(@"🔄 TestGenericViewImageResolver: resolveBackgroundImageViewResource (fallback) called for URL: %@", url.absoluteString);
    
    if (self.useGenericViewResolution) {
        NSLog(@"⚠️ TestGenericViewImageResolver: Generic resolution enabled, this fallback shouldn't be called");
    }
    
    // Create standard UIImageView for background
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = hasStretch ? UIViewContentModeScaleToFill : UIViewContentModeScaleAspectFit;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                NSLog(@"🔄 TestGenericViewImageResolver: Traditional background resolution completed for %@", url.absoluteString);
            });
        }
    });
    
    return imageView;
}

// Configuration methods
- (void)setUseGenericViewResolution:(BOOL)useGenericViewResolution {
    _useGenericViewResolution = useGenericViewResolution;
    NSLog(@"⚙️ TestGenericViewImageResolver: Generic view resolution %@", useGenericViewResolution ? @"ENABLED" : @"DISABLED");
}

- (void)setEnableExternalKVO:(BOOL)enableExternalKVO {
    _enableExternalKVO = enableExternalKVO;
    NSLog(@"⚙️ TestGenericViewImageResolver: External KVO %@", enableExternalKVO ? @"ENABLED" : @"DISABLED");
    if (enableExternalKVO) {
        NSLog(@"🔗 TestGenericViewImageResolver: MockSwiftKVOManager will handle KVO for composite views");
    }
}

- (void)logConfiguration {
    NSLog(@"📋 TestGenericViewImageResolver Configuration:");
    NSLog(@"   Generic View Resolution: %@", self.useGenericViewResolution ? @"ENABLED" : @"DISABLED");
    NSLog(@"   External KVO Management: %@", self.enableExternalKVO ? @"ENABLED" : @"DISABLED");
}

@end

@implementation ACRChatWindow {
    NSUInteger numberOfCards;
    NSMutableArray<NSString *> *adaptiveCardsPayloads;
    NSMutableArray<id> *adaptiveCardsViews;
    CGFloat adaptiveCardsWidth;
    NSString *hostConfig;
    ACOResourceResolvers *resolvers;
    ACOAdaptiveCardParseResult *errorCard;
}

- (instancetype)init
{
    return [self init:330];
}

- (instancetype)init:(CGFloat)width
{
    self = [super init];
    if (self) {
        adaptiveCardsWidth = 0;
        adaptiveCardsPayloads = [[NSMutableArray alloc] init];
        adaptiveCardsViews = [[NSMutableArray alloc] init];
        NSBundle *main = [NSBundle mainBundle];
        #if TARGET_OS_VISION
        hostConfig = [NSString stringWithContentsOfFile:[main pathForResource:@"visionOsHostConfig" ofType:@"json"]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
        #else
        hostConfig = [NSString stringWithContentsOfFile:[main pathForResource:@"sample" ofType:@"json"]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
        #endif
        resolvers = [[ACOResourceResolvers alloc] init];
    
    // Set up resolver for testing
    // CHANGE THIS LINE TO SWITCH BETWEEN DIFFERENT RESOLVERS:
    
    // Option 1: Standard ADCResolver (traditional behavior)
    // ADCResolver *resolver = [[ADCResolver alloc] init];
    // NSLog(@"🎯 ACR_VISUALIZER: Using ADCResolver for standard behavior");
    
    // Option 2: TestGenericViewImageResolver (composite view testing)
    TestGenericViewImageResolver *resolver = [TestGenericViewImageResolver sharedResolver];
    resolver.useGenericViewResolution = YES;
    resolver.enableExternalKVO = YES;
    [resolver logConfiguration];
    NSLog(@"🚀 ACR_VISUALIZER: Using TestGenericViewImageResolver for GENERIC VIEW testing");
    NSLog(@"🧪 Load GenericViewTestCard.json to see composite views with blue/green borders!");
    
    [resolvers setResourceResolver:resolver scheme:@"http"];
    [resolvers setResourceResolver:resolver scheme:@"https"];
    [resolvers setResourceResolver:resolver scheme:@"data"];

        NSString *errorMSG = @"{\"type\": \"AdaptiveCard\", \"$schema\": "
                             @"\"http://adaptivecards.io/schemas/adaptive-card.json\",\"version\": "
                             @"\"1.2\", \"body\": [ {"
                             @"\"type\": \"TextBlock\", \"text\": \"Rendering Failed\","
                             @"\"weight\": \"Bolder\", \"color\": "
                             @"\"Attention\", \"horizontalAlignment\": \"Center\""
                             @"} ] }";
        errorCard = [ACOAdaptiveCard fromJson:errorMSG];
    }
    return self;
}

- (void)insertCard:(NSString *)card
{
    [adaptiveCardsPayloads addObject:card];
    [self renderCards:card];
    numberOfCards += 1;
}

- (void)insertView:(UIView *)view
{
    [adaptiveCardsPayloads addObject:@""];
    [adaptiveCardsViews addObject:view];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return adaptiveCardsViews.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACRView *adaptiveCardView = nil;
    id view = adaptiveCardsViews[indexPath.row];
    // view will be null when accessiblity event has occured in which case redraw the adaptive cards
    if (view == [NSNull null]) {
        adaptiveCardView = [self renderCard:adaptiveCardsPayloads[indexPath.row]];
        if (adaptiveCardView) {
            adaptiveCardsViews[indexPath.row] = adaptiveCardView;
        }
    } else {
        adaptiveCardView = (ACRView *)view;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adaptiveCell" forIndexPath:indexPath];
    if (cell) {
        ((ACRChatWindowCell *)cell).adaptiveCardView = adaptiveCardView;
        [cell becomeFirstResponder];
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, cell);
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)deleteAllRows:(UITableView *)tableView
{
    [adaptiveCardsPayloads removeAllObjects];
    [adaptiveCardsViews removeAllObjects];
    numberOfCards = 0;
    [tableView reloadData];
}

- (ACRView *)renderCard:(NSString *)card
{
    NSString *jsonString = card;
    ACOHostConfigParseResult *hostconfigParseResult = [ACOHostConfig fromJson:hostConfig
                                                            resourceResolvers:resolvers];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:jsonString];

    ACRRenderResult *renderResult = nil;
    if (cardParseResult.isValid) {
        renderResult = [ACRRenderer render:cardParseResult.card
                                    config:hostconfigParseResult.config
                           widthConstraint:adaptiveCardsWidth
                                  delegate:self.adaptiveCardsDelegates
                                     theme:ACRThemeNone];
        renderResult.view.mediaDelegate = self.adaptiveCardsMediaDelegates;
    } else {
        renderResult = [ACRRenderer render:errorCard.card
                                    config:hostconfigParseResult.config
                           widthConstraint:adaptiveCardsWidth
                                  delegate:self.adaptiveCardsDelegates
                                     theme:ACRThemeNone];
    }
    #if TARGET_OS_VISION
    renderResult.view.layer.cornerRadius = 12;
    #endif
    return renderResult.view;
}

- (void)renderCards:(NSString *)card
{
    [adaptiveCardsViews addObject:[self renderCard:card]];
}

// empty the cached adaptive cards views
// only visible adaptive card view will be drawn initially, and will cause to render adaptive cards when the cards in the invisible rows become visible.
- (void)prepareForRedraw
{
    if (adaptiveCardsViews) {
        for (NSInteger i = 0; i < adaptiveCardsViews.count; i++) {
            adaptiveCardsViews[i] = [NSNull null];
        }
    }
}

@end

// configure the content cell
@implementation ACRChatWindowCell {
    NSArray<NSLayoutConstraint *> *_contentViewConstraints;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentViewConstraints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setAdaptiveCardView:(ACRView *)adaptiveCardView
{
    _adaptiveCardView = adaptiveCardView;
    if (self.adaptiveCardView) {
        if (self.contentView.subviews && self.contentView.subviews.count) {
            [self.contentView.subviews[0] removeFromSuperview];
        }
        [self.contentView addSubview:self.adaptiveCardView];
        [self updateLayoutConstraints];
    }
}

- (void)updateLayoutConstraints
{
    _contentViewConstraints = @[
        [self.adaptiveCardView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.adaptiveCardView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.contentView.heightAnchor constraintEqualToAnchor:self.adaptiveCardView.heightAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.adaptiveCardView.widthAnchor]
    ];
    [NSLayoutConstraint activateConstraints:_contentViewConstraints];
}

@end
