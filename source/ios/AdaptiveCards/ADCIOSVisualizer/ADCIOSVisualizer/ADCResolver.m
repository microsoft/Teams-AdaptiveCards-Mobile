//
//  ADCResolver.m
//  ADCIOSVisualizer
//
//  Created by Inyoung Woo on 7/11/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ADCResolver.h"

@implementation ADCResolver {
    NSMutableDictionary<NSValue *, void (^)(UIImageView *)> *_imageLoadedCallbacks;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageLoadedCallbacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (UIImageView *)resolveImageViewResource:(NSURL *)url
{
    __block UIImageView *imageView = [[UIImageView alloc] init];
    // check if custom scheme bundle exists
    if ([url.scheme isEqualToString:@"bundle"]) {
        // if bundle scheme, load an image from sample's main bundle
        UIImage *image = [UIImage imageNamed:url.pathComponents.lastObject];
        imageView.image = image;
        
        // For bundle images, apply bounds adjustment immediately since image is loaded synchronously
        [self applyImageBoundsAdjustmentToImageView:imageView];
        NSLog(@"ADCResolver: Applied immediate bounds adjustment for bundle image. Final bounds: %.1f %.1f %.1f %.1f", 
              imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
    } else {
        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
            downloadTaskWithURL:url
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                  // iOS uses NSInteger as HTTP URL status
                  NSInteger status = 200;
                  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                      status = ((NSHTTPURLResponse *)response).statusCode;
                  }
                  if (!error && status == 200) {
                      UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                      if (image) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              imageView.image = image;
                              [self triggerImageLoadedCallbackForImageView:imageView];
                          });
                      }
                  }
              }];
        [downloadPhotoTask resume];
    }
    return imageView;
}

- (UIImageView *)resolveBackgroundImageViewResource:(NSURL *)url hasStretch:(BOOL)hasStretch
{
    __block UIImageView *imageView = [[UIImageView alloc] init];
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
        downloadTaskWithURL:url
          completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
              // iOS uses NSInteger as HTTP URL status
              NSInteger status = 200;
              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                  status = ((NSHTTPURLResponse *)response).statusCode;
              }
              if (!error && status == 200) {
                  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                  if (image) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (hasStretch) {
                              imageView.image = image;
                          } else {
                              imageView.backgroundColor = [UIColor colorWithPatternImage:image];
                          }
                          [self triggerImageLoadedCallbackForImageView:imageView];
                      });
                  }
              }
          }];
    [downloadPhotoTask resume];
    return imageView;
}

#pragma mark - Image Loaded Callback System

- (BOOL)shouldAddKVOObserverForImageView:(UIImageView *)imageView {
    NSLog(@"ADCResolver: shouldAddKVOObserverForImageView called - returning NO (callbacks used instead)");
    return NO;
}

// Helper method to apply image bounds adjustment logic
- (void)applyImageBoundsAdjustmentToImageView:(UIImageView *)imageView {
    NSLog(@"ADCResolver: Applying image bounds adjustment for imageView %@", imageView);
    
    if (imageView.image) {
        CGSize imageSize = imageView.image.size;
        NSLog(@"ADCResolver: Image actual size: %.1f x %.1f", imageSize.width, imageSize.height);
        NSLog(@"ADCResolver: ImageView current frame: %@", NSStringFromCGRect(imageView.frame));
        NSLog(@"ADCResolver: ImageView current bounds: %@", NSStringFromCGRect(imageView.bounds));
    }
    
    // Apply the same bounds adjustment logic that was in the callback
    [imageView sizeToFit];
    [imageView invalidateIntrinsicContentSize];
    [imageView setNeedsLayout];
    [imageView layoutIfNeeded];
    [imageView setNeedsUpdateConstraints];
    [imageView updateConstraintsIfNeeded];
    
    // Additional fallback: if image has size but imageView bounds are still zero, set bounds directly
    if (imageView.image && (imageView.bounds.size.width == 0 || imageView.bounds.size.height == 0)) {
        CGSize imageSize = imageView.image.size;
        if (imageSize.width > 0 && imageSize.height > 0) {
            imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
            NSLog(@"ADCResolver: Set imageView bounds directly to %.1f x %.1f", imageSize.width, imageSize.height);
        }
    }
    
    NSLog(@"ADCResolver: Image bounds adjustment applied. Final bounds: %.1f %.1f %.1f %.1f", 
          imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
}

- (void)setImageLoadedCallback:(void (^)(UIImageView *))callback forImageView:(UIImageView *)imageView {
    NSLog(@"ADCResolver: Setting image loaded callback for imageView %@", imageView);
    
    if (callback && imageView) {
        NSValue *key = [NSValue valueWithNonretainedObject:imageView];
        _imageLoadedCallbacks[key] = callback;
        NSLog(@"ADCResolver: Callback stored for imageView. Total callbacks: %lu", (unsigned long)_imageLoadedCallbacks.count);
    }
}

- (void)triggerImageLoadedCallbackForImageView:(UIImageView *)imageView {
    NSLog(@"ADCResolver: triggerImageLoadedCallbackForImageView called for imageView %@", imageView);
    
    if (!imageView) {
        NSLog(@"ADCResolver: imageView is nil, cannot trigger callback");
        return;
    }
    
    NSValue *key = [NSValue valueWithNonretainedObject:imageView];
    void (^callback)(UIImageView *) = _imageLoadedCallbacks[key];
    
    if (callback) {
        NSLog(@"ADCResolver: Found callback, executing for imageView %@", imageView);
        
        // TEMPORARILY DISABLED: Apply the image bounds adjustment using the helper method
        // Let ACRView handle layout after renderer call instead
        // [self applyImageBoundsAdjustmentToImageView:imageView];
        
        callback(imageView);
        
        // Remove callback after execution to prevent memory leaks
        [_imageLoadedCallbacks removeObjectForKey:key];
        NSLog(@"ADCResolver: Callback executed and removed. Remaining callbacks: %lu", (unsigned long)_imageLoadedCallbacks.count);
    } else {
        NSLog(@"ADCResolver: No callback found for imageView %@. Available callbacks: %lu", imageView, (unsigned long)_imageLoadedCallbacks.count);
    }
}

@end
