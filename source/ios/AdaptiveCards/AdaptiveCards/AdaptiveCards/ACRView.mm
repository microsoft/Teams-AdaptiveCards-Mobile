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
#import <objc/runtime.h>

using namespace AdaptiveCards;
typedef UIImage * (^ImageLoadBlock)(NSURL *url);

// Associated object keys for external UIImageView monitoring
static const void *ACRImageViewKeyAssociationKey = &ACRImageViewKeyAssociationKey;
static const void *ACRImageViewACRViewAssociationKey = &ACRImageViewACRViewAssociationKey;
static const void *ACRImageViewTimerAssociationKey = &ACRImageViewTimerAssociationKey;
static const void *ACRImageViewAttemptCountAssociationKey = &ACRImageViewAttemptCountAssociationKey;

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
                    NSLog(@"ACR_COMPLETION_BLOCK: ObserverActionBlock called with view: %@, key: %@", view, key);
                    if (view) {
                        // check image already exists in the returned image view and register the image
                        [self registerImageFromUIImageView:view key:key];
                        
                        // Set up completion block for ANY UIImageView type (ACRUIImageView or regular UIImageView)
                        [self setupCompletionBlockForUIImageView:view withKey:key];

                        // store the image view and image element for easy retrieval
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
                            
                            // Set up completion block for ANY UIImageView type
                            [self setupCompletionBlockForUIImageView:view withKey:key];

                            // store the image view and image set element for easy retrieval
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
                            
                            // Set up completion block for ANY UIImageView type
                            [self setupCompletionBlockForUIImageView:view withKey:key];

                            // store the image view and media element for easy retrieval
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
                            
                            // Set up completion block for play button image
                            [self setupCompletionBlockForUIImageView:view withKey:key];
                            
                            // store the image view for easy retrieval
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
                            // Use completion block pattern instead of KVO
                            if ([view isKindOfClass:[ACRUIImageView class]]) {
                                ACRUIImageView *acrImageView = (ACRUIImageView *)view;
                                __weak ACRView *weakSelf = self;
                                __weak ACRUIImageView *weakView = acrImageView;
                                acrImageView.imageSetCompletionBlock = ^(UIImageView *imageView) {
                                    if (weakSelf && weakView) {
                                        [weakSelf handleImageSetForView:weakView withKey:key context:element.get()];
                                    }
                                };
                            }

                            // store the image view for easy retrieval
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
                        // Set up completion block for action icon
                        [self setupCompletionBlockForUIImageView:view withKey:key];
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
// Note: Image KVO handling has been completely removed - using completion blocks exclusively
- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([path isEqualToString:@"hidden"]) {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    } else {
        // All image KVO has been removed - this should not be called for images anymore
        NSLog(@"ACR_COMPLETION_BLOCK: WARNING: Unexpected KVO notification for path: %@. All image KVO has been removed.", path);
    }
}

// KVO methods removed - using completion blocks exclusively now

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
    // Clean up any active timers to prevent leaks
    [self cleanupAllImageViewTimers];
    NSLog(@"ACR_TIMER: ACRView dealloc called, cleaned up all timers");
}

// Clean up all timers when ACRView is deallocated
- (void)cleanupAllImageViewTimers
{
    // Iterate through all image views in the map and clean up their timers
    for (UIImageView *imageView in [_imageViewMap allValues]) {
        if (imageView) {
            [self stopTimerForImageView:imageView];
        }
    }
    
    NSLog(@"ACR_TIMER: Cleaned up timers for %lu image views", (unsigned long)[_imageViewMap count]);
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

// Handle image set completion without KVO
- (void)handleImageSetForView:(UIImageView *)imageView withKey:(NSString *)key context:(void *)context
{
    NSLog(@"ACR_COMPLETION_BLOCK: handleImageSetForView called with key: %@, context: %p, imageView: %@", key, context, imageView);
    
    if (context) {
        // image that was loaded
        UIImage *image = imageView.image;
        NSLog(@"ACR_COMPLETION_BLOCK: Image loaded with size: %@", image ? NSStringFromCGSize(image.size) : @"nil");
        
        ACOBaseCardElement *baseCardElement = _imageContextMap[key];
        if (baseCardElement) {
            NSLog(@"ACR_COMPLETION_BLOCK: Found baseCardElement for key: %@", key);
            ACRRegistration *reg = [ACRRegistration getInstance];
            ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *renderer = (ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *)[reg getRenderer:[NSNumber numberWithInt:static_cast<int>(baseCardElement.type)]];
            if (renderer && [[renderer class] conformsToProtocol:@protocol(ACRIKVONotificationHandler)]) {
                NSLog(@"ACR_COMPLETION_BLOCK: Calling configUpdateForUIImageView on renderer");
                NSMutableDictionary *imageViewMap = [self getImageMap];
                imageViewMap[key] = image;
                [renderer configUpdateForUIImageView:self acoElem:baseCardElement config:_hostConfig image:image imageView:imageView];
                NSLog(@"ACR_COMPLETION_BLOCK: configUpdateForUIImageView completed");
            } else {
                NSLog(@"ACR_COMPLETION_BLOCK: No renderer found or renderer doesn't support KVO notification protocol");
            }
        } else {
            NSLog(@"ACR_COMPLETION_BLOCK: No baseCardElement found, checking imageViewContextMap");
            id view = _imageViewContextMap[key];
            if ([view isKindOfClass:[ACRButton class]]) {
                NSLog(@"ACR_COMPLETION_BLOCK: Handling ACRButton case");
                ACRButton *button = (ACRButton *)view;
                [button setImageView:image withConfig:_hostConfig];
            } else {
                NSLog(@"ACR_COMPLETION_BLOCK: Handling background image case");
                // handle background image for adaptive card that uses resource resolver
                auto backgroundImage = [_adaptiveCard card]->GetBackgroundImage();
                renderBackgroundImage(self, backgroundImage.get(), imageView, image);
            }
        }
    } else {
        NSLog(@"ACR_COMPLETION_BLOCK: No context provided to handleImageSetForView");
    }
}

// Safer version that looks up context by key instead of using raw pointers
- (void)handleImageSetForViewUsingKey:(UIImageView *)imageView withKey:(NSString *)key
{
    NSLog(@"ACR_COMPLETION_BLOCK: handleImageSetForViewUsingKey called with key: %@, imageView: %@", key, imageView);
    
    // image that was loaded
    UIImage *image = imageView.image;
    NSLog(@"ACR_COMPLETION_BLOCK: Image loaded with size: %@", image ? NSStringFromCGSize(image.size) : @"nil");
    
    ACOBaseCardElement *baseCardElement = _imageContextMap[key];
    if (baseCardElement) {
        NSLog(@"ACR_COMPLETION_BLOCK: Found baseCardElement for key: %@", key);
        ACRRegistration *reg = [ACRRegistration getInstance];
        ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *renderer = (ACRBaseCardElementRenderer<ACRIKVONotificationHandler> *)[reg getRenderer:[NSNumber numberWithInt:static_cast<int>(baseCardElement.type)]];
        if (renderer && [[renderer class] conformsToProtocol:@protocol(ACRIKVONotificationHandler)]) {
            NSLog(@"ACR_COMPLETION_BLOCK: Calling configUpdateForUIImageView on renderer");
            NSMutableDictionary *imageViewMap = [self getImageMap];
            imageViewMap[key] = image;
            [renderer configUpdateForUIImageView:self acoElem:baseCardElement config:_hostConfig image:image imageView:imageView];
            NSLog(@"ACR_COMPLETION_BLOCK: configUpdateForUIImageView completed");
        } else {
            NSLog(@"ACR_COMPLETION_BLOCK: No renderer found or renderer doesn't support KVO notification protocol");
        }
    } else {
        NSLog(@"ACR_COMPLETION_BLOCK: No baseCardElement found, checking imageViewContextMap");
        id view = _imageViewContextMap[key];
        if ([view isKindOfClass:[ACRButton class]]) {
            NSLog(@"ACR_COMPLETION_BLOCK: Handling ACRButton case");
            ACRButton *button = (ACRButton *)view;
            [button setImageView:image withConfig:_hostConfig];
        } else {
            NSLog(@"ACR_COMPLETION_BLOCK: Handling background image case");
            // handle background image for adaptive card that uses resource resolver
            auto backgroundImage = [_adaptiveCard card]->GetBackgroundImage();
            renderBackgroundImage(self, backgroundImage.get(), imageView, image);
        }
    }
}

// Simple helper method to set up completion handling for any UIImageView (safer version without element parameter)
- (void)setupCompletionBlockForUIImageView:(UIImageView *)imageView withKey:(NSString *)key
{
    NSLog(@"ACR_COMPLETION_BLOCK: Setting up completion block for UIImageView: %@ with key: %@", [imageView class], key);
    
    if ([imageView isKindOfClass:[ACRUIImageView class]]) {
        // Use the built-in completion block for ACRUIImageView
        ACRUIImageView *acrImageView = (ACRUIImageView *)imageView;
        __weak ACRView *weakSelf = self;
        __weak ACRUIImageView *weakView = acrImageView;
        
        // Capture the key in the block
        NSString *capturedKey = [key copy];
        acrImageView.imageSetCompletionBlock = ^(UIImageView *completionImageView) {
            NSLog(@"ACR_COMPLETION_BLOCK: ACRUIImageView completion block triggered for key: %@", capturedKey);
            if (weakSelf && weakView) {
                // Use the key to look up context from our stored maps
                [weakSelf handleImageSetForViewUsingKey:weakView withKey:capturedKey];
            }
        };
        NSLog(@"ACR_COMPLETION_BLOCK: Set completion block on ACRUIImageView: %p", acrImageView);
    } else {
        // For external UIImageViews, use synchronous monitoring with associated objects
        NSLog(@"ACR_COMPLETION_BLOCK: External UIImageView detected: %@", [imageView class]);
        
        // Store completion data with the UIImageView for later triggering
        [self attachCompletionDataToImageView:imageView withKey:key];
        
        // Check if image is already set
        if (imageView.image) {
            NSLog(@"ACR_COMPLETION_BLOCK: Image already set on external UIImageView, calling completion immediately");
            [self handleImageSetForViewUsingKey:imageView withKey:key];
        } else {
            NSLog(@"ACR_COMPLETION_BLOCK: External UIImageView has no image yet, completion will be triggered when image is detected");
            [self scheduleImageCheckForView:imageView];
        }
    }
}

// Use associated objects to store completion data with external UIImageViews (safer without raw pointers)
- (void)attachCompletionDataToImageView:(UIImageView *)imageView withKey:(NSString *)key
{
    // Store only the key and ACRView reference - avoid storing raw element pointers
    objc_setAssociatedObject(imageView, ACRImageViewKeyAssociationKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(imageView, ACRImageViewACRViewAssociationKey, self, OBJC_ASSOCIATION_ASSIGN);
    
    NSLog(@"ACR_COMPLETION_BLOCK: Attached completion data to UIImageView %p with key %@", imageView, key);
}

// Schedule reliable timer-based monitoring for image changes (mimics KVO safely)
- (void)scheduleImageCheckForView:(UIImageView *)imageView
{
    // Clean up any existing timer first
    [self stopTimerForImageView:imageView];
    
    // Reset attempt count
    objc_setAssociatedObject(imageView, ACRImageViewAttemptCountAssociationKey, @0, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Start a reliable timer-based monitoring system
    [self startTimerForImageView:imageView];
}

// Start thread-safe timer for monitoring image changes
- (void)startTimerForImageView:(UIImageView *)imageView
{
    __weak UIImageView *weakImageView = imageView;
    __weak ACRView *weakSelf = self;
    
    // Use NSTimer on main queue for thread safety and reliability
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.05 // 50ms intervals
                                                     repeats:YES
                                                       block:^(NSTimer *timer) {
        UIImageView *strongImageView = weakImageView;
        ACRView *strongSelf = weakSelf;
        
        if (!strongImageView || !strongSelf) {
            [timer invalidate];
            return;
        }
        
        [strongSelf checkImageViewWithTimer:strongImageView timer:timer];
    }];
    
    // Store timer with the image view for cleanup
    objc_setAssociatedObject(imageView, ACRImageViewTimerAssociationKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSLog(@"ACR_TIMER: Started reliable timer for UIImageView %p", imageView);
}

// Thread-safe timer callback to check image status
- (void)checkImageViewWithTimer:(UIImageView *)imageView timer:(NSTimer *)timer
{
    // This runs on main thread due to NSTimer, so it's thread-safe
    NSNumber *attemptCountObj = objc_getAssociatedObject(imageView, ACRImageViewAttemptCountAssociationKey);
    int attemptCount = attemptCountObj ? [attemptCountObj intValue] : 0;
    
    if (imageView.image) {
        // Success - image loaded
        NSLog(@"ACR_TIMER: Image detected on UIImageView %p after %d attempts", imageView, attemptCount);
        [timer invalidate];
        [self handleCompletionForImageView:imageView];
        return;
    }
    
    // Increment attempt count
    attemptCount++;
    objc_setAssociatedObject(imageView, ACRImageViewAttemptCountAssociationKey, @(attemptCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Failsafe: stop after reasonable time (10 seconds = 200 attempts at 50ms)
    if (attemptCount >= 200) {
        NSLog(@"ACR_TIMER: Timeout waiting for image on UIImageView %p after %d attempts", imageView, attemptCount);
        [timer invalidate];
        [self cleanupAssociatedObjectsForImageView:imageView];
    }
}

// Handle successful image detection
- (void)handleCompletionForImageView:(UIImageView *)imageView
{
    // Get the stored completion data
    NSString *key = objc_getAssociatedObject(imageView, ACRImageViewKeyAssociationKey);
    
    if (key) {
        NSLog(@"ACR_TIMER: Calling completion for UIImageView %p with key %@", imageView, key);
        [self handleImageSetForViewUsingKey:imageView withKey:key];
    }
    
    // Clean up all associated objects and timer
    [self cleanupAssociatedObjectsForImageView:imageView];
}

// Clean up timer and associated objects
- (void)stopTimerForImageView:(UIImageView *)imageView
{
    NSTimer *existingTimer = objc_getAssociatedObject(imageView, ACRImageViewTimerAssociationKey);
    if (existingTimer && existingTimer.isValid) {
        [existingTimer invalidate];
        NSLog(@"ACR_TIMER: Stopped existing timer for UIImageView %p", imageView);
    }
}

- (void)cleanupAssociatedObjectsForImageView:(UIImageView *)imageView
{
    [self stopTimerForImageView:imageView];
    objc_setAssociatedObject(imageView, ACRImageViewKeyAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(imageView, ACRImageViewACRViewAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(imageView, ACRImageViewTimerAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(imageView, ACRImageViewAttemptCountAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

// Check if image is set and handle completion if so (used by external notification)
- (void)checkAndHandleImageSetForView:(UIImageView *)imageView
{
    NSString *key = objc_getAssociatedObject(imageView, ACRImageViewKeyAssociationKey);
    
    if (imageView.image && key) {
        // Image is ready - handle completion immediately
        [self handleImageSetForViewUsingKey:imageView withKey:key];
        [self cleanupAssociatedObjectsForImageView:imageView];
    } else {
        // Image not set yet, start reliable timer monitoring
        [self scheduleImageCheckForView:imageView];
    }
}

- (void)setContext:(ACORenderContext *)context
{
    if (context) {
        _context = context;
    }
}

// Class method for external resolvers to notify when they set an image
// This provides immediate completion without waiting for timer
+ (void)notifyImageSetOnView:(UIImageView *)imageView
{
    if (!imageView) return;
    
    // Get the associated ACRView instance
    ACRView *acrView = objc_getAssociatedObject(imageView, ACRImageViewACRViewAssociationKey);
    if (acrView) {
        NSLog(@"ACR_TIMER: External notification - stopping timer and handling completion immediately for UIImageView %p", imageView);
        [acrView checkAndHandleImageSetForView:imageView];
    }
}

@end
