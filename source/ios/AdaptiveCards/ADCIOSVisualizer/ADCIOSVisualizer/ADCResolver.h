//
//  ADCResolver.h
//  ADCResolver.h
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AdaptiveCards/AdaptiveCards.h>

@interface ADCResolver : NSObject <ACOIResourceResolver>

// Dictionary to store image loaded callbacks keyed by image view addresses
@property (nonatomic, strong) NSMutableDictionary<NSValue *, void (^)(UIImageView *)> *imageLoadedCallbacks;

// Image loaded callback system methods
- (BOOL)shouldAddKVOObserverForImageView:(UIImageView *)imageView;
- (void)setImageLoadedCallback:(void (^)(UIImageView *))callback forImageView:(UIImageView *)imageView;
- (void)triggerImageLoadedCallbackForImageView:(UIImageView *)imageView;
- (void)applyImageBoundsAdjustmentToImageView:(UIImageView *)imageView;

@end
