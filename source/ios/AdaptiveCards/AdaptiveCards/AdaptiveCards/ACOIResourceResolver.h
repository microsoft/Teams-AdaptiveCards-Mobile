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

// Protocol method to control KVO observer attachment for image views
// Return NO to prevent KVO observer from being added (useful for custom image views that handle their own observation)
// Return YES (default) to allow normal KVO observer behavior
- (BOOL)shouldAddKVOObserverForImageView:(UIImageView *)imageView;

// Protocol method to set a completion callback for image loading
// This allows the resolver to notify the AC SDK when an image has loaded,
// triggering the same refresh behavior that KVO would normally provide
- (void)setImageLoadedCallback:(void (^)(UIImageView *imageView))callback forImageView:(UIImageView *)imageView;

@end
