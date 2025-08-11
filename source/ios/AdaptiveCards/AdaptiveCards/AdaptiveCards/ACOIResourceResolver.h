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

@optional
// Granular KVO control methods - each can be implemented independently
// Return NO if the consumer wants to manage KVO externally for that specific element type
// Return YES or don't implement to use default SDK KVO behavior

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

// MARK: - Mock KVO Manager for Testing (accessible to visualizer)
@interface MockSwiftKVOManager : NSObject
+ (void)addKVOObserverForImageView:(UIImageView *)imageView acrView:(NSObject *)acrView;
@end
