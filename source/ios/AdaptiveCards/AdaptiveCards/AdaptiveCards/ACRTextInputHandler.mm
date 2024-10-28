//
//  ACRTextInputHandler
//  ACRTextInputHandler.mm
//
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "ACRTextInputHandler.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACRInputLabelView.h"
#import "NumberInput.h"
#import "TextInput.h"

@implementation ACRTextInputHandler

- (instancetype)init:(ACOBaseCardElement *)acoElem
{
    self = [super init];
    if (self) {
        std::shared_ptr<BaseCardElement> elem = [acoElem element];
        std::shared_ptr<TextInput> inputBlock = std::dynamic_pointer_cast<TextInput>(elem);
        self.id = [NSString stringWithCString:inputBlock->GetId().c_str()
                                     encoding:NSUTF8StringEncoding];
        self.maxLength = inputBlock->GetMaxLength();
        self.isRequired = inputBlock->GetIsRequired();
        std::string cpattern = inputBlock->GetRegex();
        if (!cpattern.empty()) {
            NSString *pattern = [NSString stringWithCString:cpattern.c_str() encoding:NSUTF8StringEncoding];
            self.regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        }
        self.hasValidationProperties = self.isRequired || self.maxLength || self.regexPredicate;
        self.text = [NSString stringWithCString:inputBlock->GetValue().c_str() encoding:NSUTF8StringEncoding];
        self.defaultValue = self.text;
        self._completionHandlers = [[NSMutableArray alloc] init];
        if (self.text && self.text.length) {
            self.hasText = YES;
        }
    }
    return self;
}

- (BOOL)validate:(NSError **)error
{
    return [ACRInputLabelView commonTextUIValidate:self.isRequired hasText:self.hasText predicate:self.regexPredicate text:self.text error:error];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.text = textField.text;
    self.hasText = textField.hasText;
    return YES;
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    dictionary[self.id] = self.text;
}

- (void)setFocus:(BOOL)shouldBecomeFirstResponder view:(UIView *)view
{
    UIView *inputview = ([view isKindOfClass:[UITextField class]]) ? ((UITextField *)view).inputView : view;
    if (shouldBecomeFirstResponder) {
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, view);
        [ACRInputLabelView commonSetFocus:shouldBecomeFirstResponder view:inputview];
    }
}

- (void)resetInput {
    _textField.text = self.defaultValue;
}

- (void)addObserverWithCompletion:(CompletionHandler)completion {
    [self._completionHandlers addObject:completion];
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.text = textField.text;
    self.hasText = textField.hasText;
    for(CompletionHandler completion in self._completionHandlers) {
        completion();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!_maxLength) {
        return YES;
    }

    if (range.length + range.location > textField.text.length) {
        return NO;
    }

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= _maxLength;
}


@synthesize isRequired;
@synthesize hasValidationProperties;
@synthesize id;
@synthesize hasVisibilityChanged;

@end

@implementation ACRNumberInputHandler {
    NSCharacterSet *_notDigits;
}

- (instancetype)init:(ACOBaseCardElement *)acoElem
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<NumberInput> numberInputBlock = std::dynamic_pointer_cast<NumberInput>(elem);
    self = [super init];
    if (self) {
        self.isRequired = numberInputBlock->GetIsRequired();
        auto value = numberInputBlock->GetValue();
        self.text = (value.has_value()) ? [[NSNumber numberWithDouble:value.value_or(0)] stringValue] : nil;
        self.defaultValue = self.text;
        self.hasText = self.text != nil;

        NSMutableCharacterSet *characterSets = [NSMutableCharacterSet characterSetWithCharactersInString:@"-."];
        [characterSets formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        _notDigits = [characterSets invertedSet];
        self.id = [NSString stringWithCString:numberInputBlock->GetId().c_str()
                                     encoding:NSUTF8StringEncoding];

        auto minVal = numberInputBlock->GetMin();
        self.hasMin = minVal.has_value();
        self.min = minVal.value_or(0);

        auto maxVal = numberInputBlock->GetMax();
        self.hasMax = maxVal.has_value();
        self.max = maxVal.value_or(0);
        self.hasValidationProperties = self.isRequired || self.hasMin || self.hasMax;
        self._completionHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)validate:(NSError **)error
{
    BOOL isValidated = YES;
    isValidated = [super validate:error];
    if (isValidated == YES && self.text) {
        if ([self.text rangeOfCharacterFromSet:_notDigits].location != NSNotFound) {
            return NO;
        }
        double val = [self.text doubleValue];
        if (self.hasMin && val < self.min) {
            if (error) {
                *error = [NSError errorWithDomain:ACRInputErrorDomain code:ACRInputErrorLessThanMin userInfo:nil];
            }
            return NO;
        }
        if (self.hasMax && val > self.max) {
            if (error) {
                *error = [NSError errorWithDomain:ACRInputErrorDomain code:ACRInputErrorGreaterThanMax userInfo:nil];
            }
            return NO;
        }
        return YES;
    }
    return isValidated;
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    NSError *error;
    [self validate:&error];
    dictionary[self.id] = self.text;
}
@end
