//
//  ACRSVGImageView.m
//  AdaptiveCards
//
//  Created by Abhishek on 26/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRSVGImageView.h"
#import "ACRErrors.h"
#import "Icon.h"
#import "UtiliOS.h"
#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "SVGKit.h"
#else
/// Cocoapods Imports
#import <SVGKit/SVGKit.h>
#endif

@implementation ACRSVGImageView {
    NSString *_svgPayloadURL;
    ACRRtl _rtl;
    BOOL _isFilled;
}

- (instancetype)init:(NSString *)iconURL
                 rtl:(ACRRtl)rtl
            isFilled:(BOOL)isFilled
                size:(CGSize)size
           tintColor:(UIColor *)tintColor
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _svgPayloadURL = iconURL;
        self.size = size;
        _rtl = rtl;
        _isFilled = isFilled;
        self.svgTintColor = tintColor;
        [self loadIconFromCDN];
    }
    return self;
}

- (void)loadIconFromCDN
{
    __weak ACRSVGImageView *weakSelf = self;
    [ACRSVGImageView requestIcon:_svgPayloadURL
                          filled:_isFilled
                       tintColor:_svgTintColor
                            size:_size
                             rtl:_rtl
                      completion:^(UIImage *image) {
        ACRSVGImageView *strongSelf = weakSelf;
        strongSelf.contentMode = UIViewContentModeScaleAspectFit;
        strongSelf.tintColor = strongSelf.svgTintColor;
        strongSelf.image = image;
        if (strongSelf.svgImage) {
            strongSelf.image = strongSelf.svgImage;
        }
    }];
}

+ (void)requestIcon:(NSString *)iconURL
             filled:(BOOL)filled
          tintColor:(UIColor *)tintColor
               size:(CGSize)size
                rtl:(ACRRtl)rtl
         completion:(void (^)(UIImage *))completion
{
    NSURL *url = [[NSURL alloc] initWithString:iconURL];
    [ACRSVGImageView requestIconFromCDN:url
                             completion:^(NSDictionary *_Nullable dict, __unused NSError *_Nullable error) {
                                 if (dict != nil) {
                                     BOOL success = [ACRSVGImageView prepareImage:dict
                                                                           filled:filled
                                                                        tintColor:tintColor
                                                                             size:size
                                                                              rtl:rtl
                                                                       completion:completion];
                                     if (success) {
                                         return;
                                     }
                                 }

                                 // If we reach this point, we failed to load the icon from CDN.
                                 // Show fallback.
                                 [ACRSVGImageView requestFallbackWithSize:(CGSize)size
                                                                tintColor:tintColor
                                                                      rtl:(ACRRtl)rtl
                                                               completion:completion];
                             }];
}

+ (void)requestFallbackWithSize:(CGSize)size
                      tintColor:(UIColor *)tintColor
                            rtl:(ACRRtl)rtl
                     completion:(void (^)(UIImage *))completion
{
    NSString *fallbackURLName = @"Square";
    NSString *fallBackURLString = [[NSString alloc] initWithFormat:@"%@%@/%@.json", baseFluentIconCDNURL, fallbackURLName, fallbackURLName];
    NSURL *svgURL = [[NSURL alloc] initWithString:fallBackURLString];
    [ACRSVGImageView requestIconFromCDN:svgURL
                             completion:^(NSDictionary *_Nullable dict, __unused NSError *_Nullable error) {
                                 if (dict != nil) {
                                     [ACRSVGImageView prepareImage:dict
                                                            filled:YES
                                                         tintColor:tintColor
                                                              size:size
                                                               rtl:rtl
                                                        completion:completion];
                                 }
                             }];
}

+ (void)requestIconFromCDN:(NSURL *)url
                completion:(void (^)(NSDictionary *_Nullable object, NSError *_Nullable error))completion
{
    if (url) {
        NSURLSessionDataTask *iconDataTask = [[NSURLSession sharedSession]
              dataTaskWithURL:url
            completionHandler:^(NSData *_Nullable data,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable error) {
                NSInteger status = 200;
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    status = ((NSHTTPURLResponse *)response).statusCode;
                }
                if (!error && status == 200) {
                    NSError *err;
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&err];
                    if (err) {
                        completion(nil, err);
                    } else {
                        completion(dict, nil);
                    }
                } else {
                    completion(nil, error);
                }
            }];
        [iconDataTask resume];
    } else {
        NSError *error = [NSError errorWithDomain:ACRParseErrorDomain
                                             code:ACRInputErrorValueMissing
                                         userInfo:nil];
        completion(nil, error);
    }
}

+ (NSString *)svgXMLPayloadFrom:(NSString *)path size:(CGSize)size viewPort:(CGFloat)viewPort
{
    return [[NSString alloc] initWithFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%f\" height=\"%f\" viewBox=\"0 0 %f %f\"><path d=\"%@\"/></svg>", size.width, size.height, viewPort, viewPort, path];
}

+ (BOOL)prepareImage:(NSDictionary *)svgData
              filled:(BOOL)filled
           tintColor:(UIColor *)tintColor
                size:(CGSize)size
                 rtl:(ACRRtl)rtl
          completion:(void (^)(UIImage *))completion
{
    NSString *iconFilledStyleKey = filled ? @"filled" : @"regular";
    NSDictionary *iconDict = svgData[iconFilledStyleKey];
    if (iconDict) {
        // exact size for icon may not be available, try to find closest size of icon which is available
        NSString *targetKey = [ACRSVGImageView findClosestIconSizeInArray:[iconDict allKeys] toTarget:@(size.height)];
        CGFloat viewPort = [targetKey doubleValue];
        NSArray<NSString *> *pathArray = iconDict[targetKey];
        if (pathArray != nil) {
            BOOL flipInRTL = [svgData[@"flipInRtl"] boolValue];
            NSString *path = [pathArray firstObject];
            NSString *svgXML = [ACRSVGImageView svgXMLPayloadFrom:path size:size viewPort:viewPort];
            NSData *svgXMLData = [svgXML dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
            NSInputStream *stream = [[NSInputStream alloc] initWithData:svgXMLData];
            SVGKSource *svgSource = [[SVGKSource alloc] initWithInputSteam:stream];
            SVGKImage *document = [SVGKImage imageWithSource:svgSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = tintColor ? [document.UIImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : document.UIImage;
                if (rtl == ACRRtlRTL && flipInRTL) {
                    // flip in right to left mode
                    completion([image imageWithHorizontallyFlippedOrientation]);
                }
                completion(image);
            });
            return YES;
        }
    }
    return NO;
}

+ (NSString *)findClosestIconSizeInArray:(NSArray<NSString *> *)numbers toTarget:(NSNumber *)targetNumber
{
    if (numbers.count == 0) {
        return nil;
    }

    NSString *closestNumberString = numbers[0];
    NSNumber *closestNumber = @([closestNumberString doubleValue]);
    double closestDifference = fabs([closestNumber doubleValue] - [targetNumber doubleValue]);

    for (NSString *numberString in numbers) {
        NSNumber *number = @([numberString doubleValue]);
        double currentDifference = fabs([number doubleValue] - [targetNumber doubleValue]);
        if (currentDifference < closestDifference) {
            closestDifference = currentDifference;
            closestNumberString = numberString;
        }
    }
    return closestNumberString;
}

@end
