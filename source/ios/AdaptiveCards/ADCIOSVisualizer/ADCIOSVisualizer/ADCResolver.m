//
//  ADCResolver.m
//  ADCIOSVisualizer
//
//  Created by Inyoung Woo on 7/11/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ADCResolver.h"
#import <UIKit/UIKit.h>

@implementation ADCResolver


- (UIImageView *)resolveImageViewResource:(NSURL *)url
{
    __block UIImageView *imageView = [[UIImageView alloc] init];
    NSLog(@"ADCResolver: Created UIImageView %p for URL: %@", imageView, url);
    
    // check if custom scheme bundle exists
    if ([url.scheme isEqualToString:@"bundle"]) {
        // if bundle scheme, load an image from sample's main bundle
        UIImage *image = [UIImage imageNamed:url.pathComponents.lastObject];
        NSLog(@"ADCResolver: Setting image %p on UIImageView %p", image, imageView);
        imageView.image = image;
        NSLog(@"ADCResolver: Image set complete for UIImageView %p", imageView);
        
        // Note: Since this is a regular UIImageView (not ACRUIImageView), 
        // any completion logic will be handled by ACRView when it detects the image is already set
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
                              // Optional: Notify ACRView synchronously that image was set
                              // This eliminates the need for polling/timers
                              [ACRView notifyImageSetOnView:imageView];
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
                      });
                  }
              }
          }];
    [downloadPhotoTask resume];
    return imageView;
}

@end
