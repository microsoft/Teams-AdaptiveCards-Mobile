//
//  ADCResolver.m
//  ADCIOSVisualizer
//
//  Created by Inyoung Woo on 7/11/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ADCResolver.h"

@implementation ADCResolver

- (instancetype)init {
    self = [super init];
    if (self) {
        // Default to Swift KVO enabled for testing
        _enableSwiftKVO = YES;
    }
    return self;
}

// Optional method from ACOIResourceResolver protocol to enable Swift KVO
- (BOOL)useSwiftKVOForImages {
    return _enableSwiftKVO;
}


- (UIImageView *)resolveImageViewResource:(NSURL *)url
{
    __block UIImageView *imageView = [[UIImageView alloc] init];
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
