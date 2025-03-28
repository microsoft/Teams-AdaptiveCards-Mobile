//
//  ACRChoiceSetCompactStyleTextFiled
//  ACRChoiceSetCompactStyleTextFiled.mm
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACRChoiceSetCompactStyleView.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOBundle.h"
#import "ACRActionDelegate.h"
#import "ACRBaseCardElementRenderer.h"
#import "ACRInputLabelView.h"
#import "ACRView.h"
#import "ChoiceInput.h"
#import "ChoiceSetInput.h"
#import "HostConfig.h"
#import "UtiliOS.h"

using namespace AdaptiveCards;

static inline CGRect ActiveScreenBounds()
{
    // this code is also compiled for extensions where UIApplication.sharedApplication is not available
    UIApplication *sharedApp = nil;
    if ([UIApplication respondsToSelector:NSSelectorFromString(@"sharedApplication")])
    {
        sharedApp = [UIApplication performSelector:NSSelectorFromString(@"sharedApplication")];
    }
    
    UIWindowScene *activeScene = nil;
    for (UIWindowScene *scene in sharedApp.connectedScenes)
    {
        if (scene.activationState == UISceneActivationStateForegroundActive)
        {
            activeScene = scene;
            break;
        }
    }

    if ((activeScene == nil) && (sharedApp.connectedScenes.count > 0))
    {
        activeScene = (UIWindowScene *)sharedApp.connectedScenes.anyObject;
    }

    if (activeScene != nil)
    {
        return activeScene.coordinateSpace.bounds;
    }
#if !TARGET_OS_VISION
    else
    {
        return UIScreen.mainScreen.bounds;
    }
#endif
    return CGRectZero;

}

static inline CGRect ActiveSceneBoundsForView(UIView *view)
{
    UIWindowScene *activeScene = view.window.windowScene;
    if(activeScene != nil)
    {
        return activeScene.coordinateSpace.bounds;
    }
    
    return ActiveScreenBounds();
}

@implementation ACRChoiceSetCompactStyleView {
    ACOFilteredDataSource *_filteredDataSource;
    ACOFilteredListStateManager *_stateManager;
    ACOChoiceSetFilteredStyleValidator *_validator;
    ACOFilteredListLayout *_filteredListLayout;
    NSString *_inputLabel;
    UITableView *_listView;
    UIView *_view;
    UIButton *_button;
    __weak ACRView *_rootView;
    NSInteger _wrapLines;
    NSMutableArray<CompletionHandler> *_completionHandlers;
}

- (instancetype)initWithInputChoiceSet:(ACOBaseCardElement *)acoElem
                              rootView:(ACRView *)rootView
                            hostConfig:(ACOHostConfig *)acoConfig
{
    self = [super init];
    if (self) {
        std::shared_ptr<BaseCardElement> elem = [acoElem element];
        std::shared_ptr<ChoiceSetInput> choiceSet = std::dynamic_pointer_cast<ChoiceSetInput>(elem);
        _rootView = rootView;

        // configure helper objects
        _stateManager = [[ACOFilteredListStateManager alloc] init];
        _filteredDataSource = [[ACOFilteredDataSource alloc] init:choiceSet->GetChoiceSetStyle() == ChoiceSetStyle::Filtered];
        if (!_filteredDataSource.isEnabled) {
            self.accessibilityTraits |= (UIAccessibilityTraitButton | UIAccessibilityTraitStaticText);
        }
        [self updateAccessibilityProperties];
        _validator = [[ACOChoiceSetFilteredStyleValidator alloc] init:acoElem dataSource:_filteredDataSource];

        self.spacingTop = self.window.safeAreaInsets.top + 8.0f;
        self.spacingBottom = 8.0f;

        // configure UITextField
        self.delegate = self;
        self.placeholder = _validator.placeHolder;
        self.allowsEditingTextAttributes = NO;
        self.text = _validator.userInitialChoice;

        // configure AdaptiveCards input handler
        self.id = [NSString stringWithCString:choiceSet->GetId().c_str()
                                     encoding:NSUTF8StringEncoding];
        self.isRequired = _validator.isRequired;
        self.hasValidationProperties = self.isRequired;
        auto inputLabel = choiceSet->GetLabel();
        _inputLabel = (!inputLabel.empty()) ? [NSString stringWithCString:inputLabel.c_str() encoding:NSUTF8StringEncoding] : @"";


        // configure UI
        _listView = [[UITableView alloc] init];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.accessibilityIdentifier = [NSString stringWithUTF8String:choiceSet->GetId().c_str()];
        _completionHandlers = [[NSMutableArray alloc] init];
        self.filteredListView = _listView;

        _view = [[UIView alloc] init];
        [_view addSubview:_listView];

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.isAccessibilityElement = NO;
        self.showFilteredListControl = _button;
        [_button addTarget:self action:@selector(toggleStateListView:) forControlEvents:UIControlEventTouchUpInside];
        self.rightView = _button;
        self.rightViewMode = _filteredDataSource.isEnabled ? UITextFieldViewModeUnlessEditing : UITextFieldViewModeAlways;

        ACRBaseCardElementRenderer *renderer = [[ACRRegistration getInstance] getRenderer:[NSNumber numberWithInt:(int)choiceSet->GetElementType()]];
        if (renderer && [renderer respondsToSelector:@selector(configure:rootView:baseCardElement:hostConfig:)]) {
            // configure input UI
            [renderer configure:self rootView:rootView baseCardElement:acoElem hostConfig:acoConfig];
        }

        _filteredListLayout = [[ACOFilteredListLayout alloc] initWithTopMargin:self.spacingTop bottomMargin:self.spacingBottom];
        _wrapLines = choiceSet->GetWrap() ? 0 : 1;

        [_filteredDataSource updateFilteredListForStaticTypeahead:self.text];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }

    return self;
}

- (void)updateControls
{
    if (_button.isSelected) {
        if (!_stateManager.isShowFilteredListControlSelected) {
            _button.selected = NO;
        }
    } else if (_stateManager.isShowFilteredListControlSelected) {
        _button.selected = YES;
    }

    [self updateAccessibilityProperties];

    if (_stateManager.shouldUpdateFilteredList) {
        if (_stateManager.isFilteredListVisible) {
            [self showListView];
        } else {
            [self hideListView];
        }
    }
}

- (void)updateAccessibilityProperties
{
    if (!_stateManager.isShowFilteredListControlSelected)
    {
        self.accessibilityHint = @"combo box, collapsed, double tap to activate it";
    }
    else
    {
        self.accessibilityHint = @"combo box, expanded, double tap to activate it";
    }
}

/// configures position of showFilteredListControl
- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect newBounds = [super rightViewRectForBounds:bounds];
    newBounds.origin.x = newBounds.origin.x - self.layoutMargins.right;
    return newBounds;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!_filteredDataSource.isEnabled) {
        BOOL prevState = _stateManager.isFilteredListVisible;
        // don't show keyboard if filtering is not enabled
        [self endEditing:YES];

        // if prevState was visible, endEditing will toggleState the state,
        // so skip the toggleState
        if (!prevState) {
            [_stateManager toggleState];
            [self updateControls];
        }

        if (_stateManager.isFilteredListVisible) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _listView);
        } else {
            // announce layout change, and move the VO focus to the filtered list
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
        }
    } else {
        [_stateManager expanded];
        [self updateControls];
    }
}

/// mainly used in checking the user input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!_filteredDataSource.isEnabled) {
        // we don't want to editing the title of choices
        return NO;
    }

    // find the newly edited string
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    // implemented fluentUI north star behavior of removing the
    // filtered list when input field is empty
    if ([newString length]) {
        [_filteredDataSource updateFilteredListForStaticTypeahead:newString];
        [_stateManager expanded];
        if (!_stateManager.shouldUpdateFilteredList) {
            [_listView reloadData];
        }
    } else {
        [self resetFilteredList];
    }

    [self updateControls];
    return YES;
}

- (void)resetFilteredList
{
    [_filteredDataSource resetFilter];
    [_listView reloadData];
}

/// handles `return` key
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_stateManager collapsed];
    [self updateControls];
    // ask UIKit to dimiss the keyboard
    [self resignFirstResponder];
    return YES;
}

- (void)filterList:(NSString *)text
{
    [_filteredDataSource updateFilteredListForStaticTypeahead:text];
}

- (void)toggleStateListView:(UIButton *)button
{
    [_stateManager toggleState];
    [self updateControls];
}

- (BOOL)resignFirstResponder
{
    [_stateManager collapsed];
    [self updateControls];
    return [super resignFirstResponder];
}

- (void)showListView
{
    [self.window addSubview:_view];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [_listView reloadData];
    if (!_filteredDataSource.isEnabled) {
        // _litView is first responder if keyboard is not shown
        [_listView becomeFirstResponder];
    }
}

- (void)hideListView
{
    [_view removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutFilterredView];
}

// layout the filtered view
- (void)layoutFilterredView
{
    CGPoint position = [self.superview convertPoint:self.frame.origin toView:nil];
    CGSize windowSize;
    if (self.window != nil)
    {
        windowSize = self.window.bounds.size;
    }
    else
    {
        CGRect sceneBounds = ActiveSceneBoundsForView(self);
        windowSize = sceneBounds.size;
    }

    UIViewController *viewController = traverseResponderChainForUIViewController(_rootView);
    CGRect frame = viewController.view.frame;
    if (frame.size.width == 0 || frame.size.height == 0) {
        frame = CGRectMake(0, 0, windowSize.width, windowSize.height);
    }

    CGFloat x = (viewController.view.superview) ? [viewController.view.superview convertPoint:self.frame.origin toView:nil].x : 0;
    CGPoint inputPosition = [self convertPoint:self.frame.origin toView:_rootView];
    CGRect rootViewFrame = [self.superview convertRect:_rootView.frame toView:nil];

    [_filteredListLayout refreshDimension:windowSize.height
                                inputYPos:inputPosition.y
                              inputHeight:self.frame.size.height
                                     yPos:position.y
                            rootViewFrame:rootViewFrame];

    _view.frame = CGRectMake(x, _filteredListLayout.y, frame.size.width, _filteredListLayout.height);
    _listView.frame = _view.bounds;
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSValue *frameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    if (frameValue) {
        _filteredListLayout.keyboardFrame = [frameValue CGRectValue];
        if (_stateManager.isFilteredListVisible == NO) {
            return;
        }
        NSNumber *durationNumber = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        if (durationNumber) {
            CGFloat keyboardAnimationDuration = [durationNumber doubleValue];
            [UIView animateWithDuration:keyboardAnimationDuration
                             animations:^void {
                                 [self layoutFilterredView];
                             }];
        }
    }
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    _filteredListLayout.keyboardFrame = CGRectZero;
    if (_stateManager.isFilteredListVisible == NO) {
        return;
    }
    NSNumber *durationNumber = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    if (durationNumber) {
        CGFloat keyboardAnimationDuration = [durationNumber doubleValue];
        [UIView animateWithDuration:keyboardAnimationDuration
                         animations:^void {
                             [self layoutFilterredView];
                         }];
    }
}

- (void)setFocus:(BOOL)shouldBecomeFirstResponder view:(UIView *)view
{
    self.accessibilityLabel = view.accessibilityLabel;
    if (shouldBecomeFirstResponder) {
        [_stateManager expanded];
        [self updateControls];
        [_listView becomeFirstResponder];
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _listView);
    } else {
        [view resignFirstResponder];
    }
}

- (BOOL)validate:(NSError * __autoreleasing *)error
{
    return [_validator isValid:self.text];
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    dictionary[self.id] = [_validator getValue:self.text];
}

- (void)addObserverWithCompletion:(CompletionHandler)completion {
    [_completionHandlers addObject:completion];
}

- (void)resetInput {
    self.text = _validator.userInitialChoice;
}

- (void)notifyDelegates {
    for(CompletionHandler completion in _completionHandlers) {
        completion();
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filterred-cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [_filteredDataSource getItemAt:indexPath.row];
    cell.textLabel.numberOfLines = _wrapLines;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", _inputLabel, cell.textLabel.text];
    cell.accessibilityValue = [NSString stringWithFormat:@"%ld of %ld", indexPath.row + 1, [self tableView:tableView numberOfRowsInSection:0]];
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@, %@", self.id, cell.textLabel.text];
    cell.accessibilityTraits = UIAccessibilityTraitButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.text = [_filteredDataSource getItemAt:indexPath.row];
    [self filterList:self.text];

    [_stateManager collapsed];
    [self updateControls];

    [self notifyDelegates];
    [self resignFirstResponder];
}

@synthesize hasValidationProperties;

@synthesize id;

@synthesize isRequired;

@synthesize hasVisibilityChanged;
@end

@implementation ACOFilteredDataSource {
    NSMutableArray<NSString *> *_unfilteredList;
    NSArray<NSString *> *_filteredList;
    NSMutableArray<NSString *> *_staticUnfilteredList;
    NSArray<NSString *> *_staticFilteredList;
    NSArray<NSString *> *_dynamicFilteredList;
    NSString *_filter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _staticUnfilteredList = [[NSMutableArray alloc] init];
        _staticFilteredList = _staticUnfilteredList;
        _dynamicFilteredList = [[NSMutableArray alloc] init];
        _filteredList = _staticFilteredList;
        _filter = @"SELF CONTAINS[c] %@";
        _isEnabled = YES;
    }
    return self;
}

- (instancetype)init:(BOOL)filteringEnabled
{
    self = [self init];
    if (self) {
        _isEnabled = filteringEnabled;
    }
    return self;
}

- (void)addToSource:(NSString *)item
{
    if (item) {
        [_staticUnfilteredList addObject:item];
    }
}

- (NSUInteger)count
{
    return !_filteredList ? 0 : _filteredList.count;
}

- (NSString *)getItemAt:(NSInteger)index
{
    return (index < 0 or (NSUInteger)index >= self.count) ? @"" : _filteredList[index];
}

- (void)updateFilteredListForStaticTypeahead:(NSString *)key
{
    if (!self.isEnabled) {
        return;
    }
    if (!key || key.length == 0) {
        [self resetFilter];
        _staticFilteredList = _staticUnfilteredList;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:_filter, key.lowercaseString];
        _filteredList = [_unfilteredList filteredArrayUsingPredicate:predicate];
        _staticFilteredList = [_staticUnfilteredList filteredArrayUsingPredicate:predicate];
        _filteredList = _staticFilteredList;
    }
}

- (void)updateFilteredListForDynamicTypeahead:(NSDictionary *)choices
{
    if (!self.isEnabled) {
        return;
    }
    if (!choices || choices.count == 0) {
        [self resetFilter];
        _dynamicFilteredList = @[];
    } else {
        NSMutableArray *dynamicList = [[NSMutableArray alloc] init];
        for (id item in choices) {
            [dynamicList addObject:item];
        }
        _dynamicFilteredList = dynamicList;
        _filteredList = _dynamicFilteredList;
    }
}

- (void)mergeStaticAndDynamicFilteredList
{
    NSMutableArray *mergedList = [[NSMutableArray alloc] init];
    for (id item in _dynamicFilteredList) {
        [mergedList addObject:item];
    }
    for (id item in _staticFilteredList) {
        [mergedList addObject:item];
    }
    _filteredList = mergedList;
}

- (void)updateFilteredListForStaticAndDynamicTypeahead:(NSString *)key dynamicChoices:(NSDictionary *)choices
{
    [self updateFilteredListForStaticTypeahead:key];
    [self updateFilteredListForDynamicTypeahead:choices];
    [self mergeStaticAndDynamicFilteredList];
}

- (BOOL)findMatch:(NSString *)queryString
{
    return [_filteredList containsObject:queryString];
}

- (NSRange)getHighlightRangeForSearchText:(NSString *)searchText resultText:(NSString *)resultText
{
    return [resultText rangeOfString:searchText options:NSCaseInsensitiveSearch];
}

- (void)resetFilter
{
    _filteredList = _staticUnfilteredList;
}

@end

@implementation ACOFilteredListStateManager {
    NSInteger _filteredListVisibility;
    BOOL _showFilstedListControlState;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filteredListVisibility = -1;
    }
    return self;
}

- (BOOL)shouldUpdateFilteredList
{
    return _filteredListVisibility == 1 || _filteredListVisibility == -1;
}

- (BOOL)isFilteredListVisible
{
    return _filteredListVisibility > 0;
}

- (BOOL)isShowFilteredListControlSelected
{
    return _showFilstedListControlState;
}

- (void)expanded
{
    [self incrementFilteredListVisibility];
    _showFilstedListControlState = YES;
}

- (void)collapsed
{
    [self decrementFilteredListVisibility];
    _showFilstedListControlState = NO;
}

- (void)incrementFilteredListVisibility
{
    if (_filteredListVisibility > 0) {
        _filteredListVisibility += 1;
    } else {
        _filteredListVisibility = 1;
    }
}

- (void)decrementFilteredListVisibility
{
    if (_filteredListVisibility > 0) {
        _filteredListVisibility = -1;
    } else {
        _filteredListVisibility -= 1;
    }
}

- (void)toggleState
{
    if (self.isFilteredListVisible) {
        [self collapsed];
    } else {
        [self expanded];
    }
}

@end

@implementation ACOChoiceSetFilteredStyleValidator {
    NSMutableDictionary<NSString *, NSString *> *_staticListTitlesMap;
    NSMutableDictionary<NSString *, NSString *> *_dynamicListTitlesMap;
}

- (instancetype)init:(ACOBaseCardElement *)acoElem dataSource:(ACOFilteredDataSource *)dataSource
{
    self = [super init];
    if (self) {
        std::shared_ptr<BaseCardElement> elem = [acoElem element];
        std::shared_ptr<ChoiceSetInput> choiceSet = std::dynamic_pointer_cast<ChoiceSetInput>(elem);
        self.isRequired = choiceSet->GetIsRequired();
        self.placeHolder = [NSString stringWithCString:choiceSet->GetPlaceholder().c_str() encoding:NSUTF8StringEncoding];

        _staticListTitlesMap = [[NSMutableDictionary alloc] init];
        _dynamicListTitlesMap = [[NSMutableDictionary alloc] init];
        NSString *defaultValue = [NSString stringWithCString:choiceSet->GetValue().c_str()
                                                    encoding:NSUTF8StringEncoding];
        for (auto choice : choiceSet->GetChoices()) {
            NSString *title = [NSString stringWithCString:choice->GetTitle().c_str() encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:choice->GetValue().c_str() encoding:NSUTF8StringEncoding];
            _staticListTitlesMap[title] = value;
            if ([value isEqualToString:defaultValue]) {
                _userInitialChoice = title;
            }
            [dataSource addToSource:title];
        }
    }
    return self;
}

- (BOOL)isValid:(NSString *)input
{
    BOOL isValid = YES;
    if (self.isRequired) {
        isValid = input != nil && input.length;
        isValid = isValid ? [_staticListTitlesMap objectForKey:input] != nil || [_dynamicListTitlesMap objectForKey:input] != nil : NO;
    } else if (input && input.length) {
        isValid = ([_staticListTitlesMap objectForKey:input] != nil || [_dynamicListTitlesMap objectForKey:input] != nil);
    }
    return isValid;
}

- (NSString *)getValue:(NSString *)input
{
    if (input && input.length) {
        NSString *value = [_staticListTitlesMap objectForKey:input];
        return value ? value : ([_dynamicListTitlesMap objectForKey:input] ?: @"");
    }
    return @"";
}

- (void)updateDynamicTitleMap:(NSDictionary *)titleMap
{
    [_dynamicListTitlesMap removeAllObjects];
    for (id key in titleMap) {
        _dynamicListTitlesMap[key] = [titleMap objectForKey:key];
    }
}

@end

@implementation ACOFilteredListLayout

- (instancetype)initWithTopMargin:(CGFloat)top bottomMargin:(CGFloat)bottom
{
    self = [super init];
    if (self) {
        self.topMargin = top;
        self.bottomMargin = bottom;
    }
    return self;
}

- (BOOL)shouldDrawBelow:(CGFloat)windowHeight inputHeight:(CGFloat)inputHeight yPos:(CGFloat)yPos
{
    return windowHeight - (yPos + inputHeight) - self.keyboardFrame.size.height > yPos - (self.topMargin + self.bottomMargin);
}

- (BOOL)doesKeyboardOverlap:(CGRect)rootViewFrame
{
    return (self.keyboardFrame.size.height > 0 && CGRectIntersectsRect(rootViewFrame, self.keyboardFrame));
}

- (void)refreshDimension:(CGFloat)windowHeight inputYPos:(CGFloat)inputYPos inputHeight:(CGFloat)inputHeight yPos:(CGFloat)yPos rootViewFrame:(CGRect)rootViewFrame
{
    if ([self shouldDrawBelow:windowHeight inputHeight:inputHeight yPos:yPos]) {
        self.y = yPos + inputHeight;
        self.height = windowHeight - self.y - self.keyboardFrame.size.height;
    } else {
        self.y = self.topMargin;
        self.height = yPos - (self.topMargin + self.bottomMargin);
        if ([self doesKeyboardOverlap:rootViewFrame]) {
            self.height = (self.keyboardFrame.origin.y - (self.topMargin + self.bottomMargin) - (rootViewFrame.size.height - inputYPos));
        }
    }
}

@end
