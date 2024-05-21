//
//  ACRRatingInputDataSource.m
//  AdaptiveCards
//
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRRatingInputDataSource.h"
#import "ACRColumnSetView.h"
#import "ACRIBaseCardElementRenderer.h"
#import "ACRInputLabelView.h"
#import "ACRUILabel.h"
#import "HostConfig.h"
#import <Foundation/Foundation.h>

using namespace AdaptiveCards;

@implementation ACRRatingInputDataSource

- (instancetype)initWithInputRating:(std::shared_ptr<RatingInput> const &)ratingInput
                     WithHostConfig:(std::shared_ptr<HostConfig> const &)hostConfig
{
    self = [super init];

    self.id = [[NSString alloc] initWithCString:ratingInput->GetId().c_str()
                                       encoding:NSUTF8StringEncoding];
    self.hasValidationProperties = self.isRequired;
    self.delegateSet = [NSMutableSet set];
    return self;
}

- (BOOL)validate:(NSError **)error
{
    if (self.isRequired) {
        return [_ratingView getValue] != -1;
    }
    return YES;
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    dictionary[self.id] = @([_ratingView getValue]);
}

- (void)setFocus:(BOOL)shouldBecomeFirstResponder view:(UIView *)view
{
    [ACRInputLabelView commonSetFocus:shouldBecomeFirstResponder view:_ratingView];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, _ratingView);
}

- (void)addObserverForValueChange:(id<ACRInputChangeDelegate>)delegate
{
    _ratingView.ratingValueChangeDelegate = self;
    [delegateSet addObject:delegate];
}

- (void)didChangeValueTo:(NSInteger)newValue {
    for (NSObject<ACRInputChangeDelegate> *delegate in delegateSet) {
        if (delegate && [delegate respondsToSelector:@selector(inputValueChanged)]) {
            [delegate inputValueChanged];
        }
    }
}

@synthesize isRequired;
@synthesize hasValidationProperties;
@synthesize hasVisibilityChanged;
@synthesize delegateSet;



@end
