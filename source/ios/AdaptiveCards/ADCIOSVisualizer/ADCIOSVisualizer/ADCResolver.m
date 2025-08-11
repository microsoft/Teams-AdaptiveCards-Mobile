//
//  ADCResolver.m
//  ADCIOSVisualizer
//
//  Created by Inyoung Woo on 7/11/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ADCResolver.h"
#import <AdaptiveCards/ACOIResourceResolver.h>

@implementation ADCResolver

// Helper method to set up external KVO when SDK KVO is disabled
- (void)setupExternalKVOForImageView:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: Setting up external KVO for imageView %p (Mock - ready for real implementation)", imageView);
    
    // CRITICAL: Actually set up KVO to replicate SDK behavior
    // This mimics what the SDK would do in observeValueForKeyPath
    [imageView addObserver:self 
                forKeyPath:@"image" 
                   options:NSKeyValueObservingOptionNew 
                   context:(__bridge void *)imageView];
    
    NSLog(@"✅ ADCResolver: External KVO observer added - will handle image sizing when image loads");
}

// Replicate SDK's observeValueForKeyPath behavior
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"] && [object isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)object;
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        
        if (newImage && [newImage isKindOfClass:[UIImage class]]) {
            NSLog(@"🎯 External KVO: Image changed for imageView %p - applying sizing logic", imageView);
            
            // Remove observer immediately (like SDK does)
            [imageView removeObserver:self forKeyPath:@"image"];
            
            // Apply the sizing logic that the SDK renderer would do
            [self applySDKLikeSizingToImageView:imageView withImage:newImage];
        }
    }
}

// Replicate what SDK renderers do for image sizing
- (void)applySDKLikeSizingToImageView:(UIImageView *)imageView withImage:(UIImage *)image {
    NSLog(@"🔧 External KVO: Applying SDK-like sizing to imageView %p", imageView);
    
    // Set content mode to aspect fit (like SDK does)
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Get image intrinsic size
    CGSize imageSize = image.size;
    NSLog(@"🔧 External KVO: Image size: %.2f x %.2f", imageSize.width, imageSize.height);
    
    if (imageSize.width > 0 && imageSize.height > 0) {
        // Calculate aspect ratio
        CGFloat aspectRatio = imageSize.width / imageSize.height;
        NSLog(@"🔧 External KVO: Aspect ratio: %.3f", aspectRatio);
        
        // Remove any existing aspect ratio constraints
        NSArray<NSLayoutConstraint *> *constraintsToRemove = [imageView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint *constraint, NSDictionary *bindings) {
            return (constraint.firstItem == imageView && constraint.secondItem == imageView &&
                    constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondAttribute == NSLayoutAttributeHeight);
        }]];
        
        if (constraintsToRemove.count > 0) {
            [imageView removeConstraints:constraintsToRemove];
            NSLog(@"🔧 External KVO: Removed %lu existing aspect constraints", (unsigned long)constraintsToRemove.count);
        }
        
        // Add aspect ratio constraint
        NSLayoutConstraint *aspectConstraint = [NSLayoutConstraint constraintWithItem:imageView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:imageView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:aspectRatio
                                                                             constant:0];
        aspectConstraint.priority = 999; // High priority but not required
        [imageView addConstraint:aspectConstraint];
        
        NSLog(@"🔧 External KVO: Added aspect ratio constraint: %.3f", aspectRatio);
    }
    
    // Trigger layout update (like SDK does)
    [imageView setNeedsLayout];
    [imageView.superview setNeedsLayout];
    
    // Find and update parent content holding view if possible
    UIView *currentView = imageView.superview;
    while (currentView) {
        NSString *className = NSStringFromClass([currentView class]);
        if ([className containsString:@"ACRContentHolding"]) {
            [currentView setNeedsLayout];
            NSLog(@"🔧 External KVO: Triggered layout on %@", className);
            break;
        }
        currentView = currentView.superview;
    }
    
    NSLog(@"✅ External KVO: SDK-like sizing applied successfully");
}


- (UIImageView *)resolveImageViewResource:(NSURL *)url
{
    NSLog(@"🔧 ADCResolver: resolveImageViewResource called with URL: %@", url.absoluteString);
    
    __block UIImageView *imageView = [[UIImageView alloc] init];
    
    // Setup external KVO when SDK KVO is disabled
    [self setupExternalKVOForImageView:imageView];
    
    // check if custom scheme bundle exists
    if ([url.scheme isEqualToString:@"bundle"]) {
        // if bundle scheme, load an image from sample's main bundle
        UIImage *image = [UIImage imageNamed:url.pathComponents.lastObject];
        imageView.image = image;
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
    NSLog(@"🔧 ADCResolver: resolveBackgroundImageViewResource called with URL: %@", url.absoluteString);
    
    __block UIImageView *imageView = [[UIImageView alloc] init];
    
    // Setup external KVO when SDK KVO is disabled  
    [self setupExternalKVOForImageView:imageView];
    
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
                      });
                  }
              }
          }];
    [downloadPhotoTask resume];
    return imageView;
}

#pragma mark - Granular KVO Control Protocol Methods

// Image Element KVO Control
- (BOOL)shouldAddKVOObserverForImageElement:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: Image KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for Image elements
}

// ImageSet Element KVO Control  
- (BOOL)shouldAddKVOObserverForImageSetElement:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: ImageSet KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for ImageSet elements
}

// BackgroundImage KVO Control
- (BOOL)shouldAddKVOObserverForBackgroundImage:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: BackgroundImage KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for BackgroundImage
}

// Media Element KVO Control
- (BOOL)shouldAddKVOObserverForMediaElement:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: Media KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for Media elements
}

// Media Play Button KVO Control
- (BOOL)shouldAddKVOObserverForMediaPlayButton:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: Media PlayButton KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for Media PlayButton
}

// TextInput Icon KVO Control
- (BOOL)shouldAddKVOObserverForTextInputIcon:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: TextInput Icon KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for TextInput Icon
}

// Action Icon KVO Control
- (BOOL)shouldAddKVOObserverForActionIcon:(UIImageView *)imageView {
    NSLog(@"🎯 ADCResolver: Action Icon KVO disabled for imageView %p - using external KVO", imageView);
    return NO;  // Disable SDK KVO for Action Icon
}

@end
