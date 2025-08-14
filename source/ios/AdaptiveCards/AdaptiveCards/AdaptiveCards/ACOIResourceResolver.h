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

// Swift KVO control - if implemented and returns YES, SDK will use Swift block-based KVO
// instead of traditional addObserver/removeObserver pattern for better thread safety
- (BOOL)useSwiftKVOForImages;

@end
