//
//  ACRTextField
//  ACRTextField.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRTextField.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACRInputLabelView.h"
#import "TextInput.h"


@implementation ACRTextField {
    UIButton *_acrClearButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    // Set border style (rounded rect)
    self.borderStyle = UITextBorderStyleRoundedRect;

    // Set the placeholder with a single space as in the xib
    self.placeholder = @" ";

    // Set natural text alignment
    self.textAlignment = NSTextAlignmentNatural;

    // Setup font and minimum font size
    self.font = [UIFont systemFontOfSize:15];
    self.minimumFontSize = 15;

    self.clearButtonMode = UITextFieldViewModeNever;
    _acrClearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _acrClearButton.tintColor = UIColor.secondaryLabelColor;
    _acrClearButton.accessibilityLabel = @"Clear text";
    UIImage *clearImage = [[UIImage systemImageNamed:@"xmark.circle.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_acrClearButton setImage:clearImage forState:UIControlStateNormal];
    [_acrClearButton addTarget:self action:@selector(acr_clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = _acrClearButton;
    self.rightViewMode = UITextFieldViewModeNever;
    [self addTarget:self action:@selector(updateClearButtonVisibility) forControlEvents:UIControlEventEditingChanged];

    // Automatically enable the return key when appropriate
    self.enablesReturnKeyAutomatically = YES;

    // Set placeholder text color using Key-Value Coding
    UIColor *placeholderColor = [UIColor colorWithRed:0.5058823529
                                                green:0.5058823529
                                                 blue:0.5058823529
                                                alpha:1];
    @try {
        [self setValue:placeholderColor forKeyPath:@"placeholderLabel.textColor"];
    } @catch (NSException *exception) {
        // Fallback if the placeholderLabel property is not available.
        NSLog(@"Placeholder text color not set: %@", exception);
    }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    if (self.rightView == _acrClearButton) {
        return [super clearButtonRectForBounds:bounds];
    }
    return [super rightViewRectForBounds:bounds];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateClearButtonVisibility];
}

- (void)acr_clearTextField:(UIButton *)sender
{
    self.text = @"";
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)updateClearButtonVisibility
{
    if (self.rightView == _acrClearButton) {
        self.rightViewMode = self.text.length ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    }
}

- (void)dismissNumPad
{
    [self resignFirstResponder];
}

@end

@implementation ACRTextEmailField : ACRTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    // Set the border style to rounded rect.
    self.borderStyle = UITextBorderStyleRoundedRect;

    // Set a placeholder with a single space.
    self.placeholder = @" ";

    // Align text naturally.
    self.textAlignment = NSTextAlignmentNatural;

    // Clear text when editing begins.
    self.clearsOnBeginEditing = YES;

    // Set the minimum font size.
    self.minimumFontSize = 17;

    // Set the font (system, size 14).
    self.font = [UIFont systemFontOfSize:14];

    // Setup text input traits: email keyboard and email content type.
    self.keyboardType = UIKeyboardTypeEmailAddress;
    self.textContentType = UITextContentTypeEmailAddress;

    // Set the placeholder label's text value via KVC.
    UIColor *placeholderValue = [UIColor colorWithRed:0.5058823529
                                                green:0.5058823529
                                                 blue:0.5058823529
                                                alpha:1.0];
    @try {
        // Note: Accessing placeholderLabel is not officially supported.
        [self setValue:placeholderValue forKeyPath:@"placeholderLabel.textValue"];
    } @catch (NSException *exception) {
        NSLog(@"Unable to set placeholderLabel.textValue: %@", exception);
    }
}

@end

@implementation ACRTextTelelphoneField : ACRTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    // Set border style (rounded rect) and placeholder text.
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.placeholder = @" ";

    // Set natural text alignment.
    self.textAlignment = NSTextAlignmentNatural;

    // Set minimum font size and font.
    self.minimumFontSize = 17;
    self.font = [UIFont systemFontOfSize:14];

    // Configure text input traits.
    self.keyboardType = UIKeyboardTypePhonePad;
    self.enablesReturnKeyAutomatically = YES;

    // Set the placeholder label's textColor via KVC.
    UIColor *placeholderColor = [UIColor colorWithRed:0.5058823529
                                                green:0.5058823529
                                                 blue:0.5058823529
                                                alpha:1.0];
    @try {
        [self setValue:placeholderColor forKeyPath:@"placeholderLabel.textColor"];
    } @catch (NSException *exception) {
        NSLog(@"Unable to set placeholderLabel.textColor: %@", exception);
    }
}

@end

@implementation ACRTextUrlField : ACRTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    // Set border style to rounded rect and a placeholder containing a single space.
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.placeholder = @" ";

    // Set natural text alignment.
    self.textAlignment = NSTextAlignmentNatural;

    // Set minimum font size and font.
    self.minimumFontSize = 17;
    self.font = [UIFont systemFontOfSize:14];

    // Configure text input traits.
    self.keyboardType = UIKeyboardTypeURL;
    self.enablesReturnKeyAutomatically = YES;

    // Set the placeholderLabel's text color via KVC.
    UIColor *placeholderColor = [UIColor colorWithRed:0.50588235294117645
                                                green:0.50588235294117645
                                                 blue:0.54509803921568623
                                                alpha:1];
    @try {
        [self setValue:placeholderColor forKeyPath:@"placeholderLabel.textColor"];
    } @catch (NSException *exception) {
        NSLog(@"Unable to set placeholderLabel.textColor: %@", exception);
    }
}

@end
