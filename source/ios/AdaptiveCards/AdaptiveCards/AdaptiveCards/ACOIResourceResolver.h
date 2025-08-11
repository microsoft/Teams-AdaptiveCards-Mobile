//
//  ACOIResourceResolver.h
//  ACOIResourceResolver
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ACOIResourceResolver

// only one IF per scheme is supported
@optional
- (UIImage *)resolveImageResource:(NSURL *)url;

- (UIImageView *)resolveImageViewResource:(NSURL *)url;

- (UIImageView *)resolveBackgroundImageViewResource:(NSURL *)url hasStretch:(BOOL)hasStretch;

// EXTENDED VIEW RESOLUTION - Support for composite views (like TeamsUI ImageView)
// These methods allow returning generic UIViews instead of UIImageViews
// The SDK will check for these methods first via respondsToSelector:
// If implemented, these take precedence over the UIImageView methods above
// The returned UIView should manage its own image loading and layout

// Resolve to a generic view that manages its own image loading (e.g., composite views)
- (UIView *)resolveImageViewAsGenericView:(NSURL *)url;

// Resolve background image to a generic view that manages its own image loading
- (UIView *)resolveBackgroundImageViewAsGenericView:(NSURL *)url hasStretch:(BOOL)hasStretch;

// Granular KVO control methods - each can be implemented independently
// Return NO if the consumer wants to manage KVO externally for that specific element type
// Return YES or don't implement to use default SDK KVO behavior
// These methods are checked with respondsToSelector: so implementation is optional

// Control KVO for Image elements
- (BOOL)shouldAddKVOObserverForImageElement:(UIImageView *)imageView;

// Control KVO for ImageSet elements
- (BOOL)shouldAddKVOObserverForImageSetElement:(UIImageView *)imageView;

// Control KVO for Media poster images
- (BOOL)shouldAddKVOObserverForMediaElement:(UIImageView *)imageView;

// Control KVO for Media play button images
- (BOOL)shouldAddKVOObserverForMediaPlayButton:(UIImageView *)imageView;

// Control KVO for TextInput icon images
- (BOOL)shouldAddKVOObserverForTextInputIcon:(UIImageView *)imageView;

// Control KVO for Action icon images
- (BOOL)shouldAddKVOObserverForActionIcon:(UIImageView *)imageView;

// Backward compatibility - if implemented, overrides all specific methods above
- (BOOL)shouldAddKVOObserverForImageView:(UIImageView *)imageView;

@end
