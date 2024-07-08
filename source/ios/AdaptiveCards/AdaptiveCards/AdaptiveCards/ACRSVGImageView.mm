//
//  ACRSVGImageView.m
//  AdaptiveCards
//
//  Created by Abhishek on 26/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRSVGImageView.h"
#import "Icon.h"
#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "SVGKit.h"
#else
/// Cocoapods Imports
#import <SVGKit/SVGKit.h>
#endif

@implementation ACRSVGImageView
{
    NSString *_svgPayloadURL;
    ACRRtl _rtl;
}

- (instancetype)init:(NSString *)iconURL
                 rtl:(ACRRtl)rtl
                size:(CGSize)size
           tintColor:(UIColor *)tintColor;
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self)
    {
        _svgPayloadURL = iconURL;
        self.size = size;
        _rtl = rtl;
        self.svgTintColor = tintColor;
        [self loadIconFromCDN];
    }
    return self;
}

-(void)loadIconFromCDN
{
    NSURL *svgURL = [[NSURL alloc] initWithString:_svgPayloadURL];
    __weak ACRSVGImageView *weakSelf = self;
    [self makeIconCDNRequestWithURL:svgURL
                         completion:^(NSDictionary * _Nullable dict, NSError * _Nullable error) {
        ACRSVGImageView *strongSelf = weakSelf;
        if (dict != nil)
        {
            [strongSelf updateImageWithSVGData: dict];
        }
        else
        {
            [strongSelf showUnavailableIcon];
        }
    }];
}

- (void)makeIconCDNRequestWithURL:(NSURL *)url
                       completion:(void (^)(NSDictionary * _Nullable object, NSError * _Nullable error))completion
{
    if (url)
    {
        NSURLSessionDataTask *iconDataTask = [[NSURLSession sharedSession]
                                              dataTaskWithURL:url
                                              completionHandler:^(NSData * _Nullable data,
                                                                  NSURLResponse * _Nullable response,
                                                                  NSError * _Nullable error) {
            NSInteger status = 200;
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                status = ((NSHTTPURLResponse *)response).statusCode;
            }
            if (!error && status == 200)
            {
                NSError *err;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&err];
                if(err)
                {
                    completion(nil, err);
                }
                else
                {
                    completion(dict, nil);
                }
            }
            else
            {
                completion(nil, error);
            }
        }];
        [iconDataTask resume];
    }
    else 
    {
        [self showUnavailableIcon];
    }
}

- (void)updateImageWithSVGData:(NSDictionary *)svgData
{
    NSArray<NSString *> *svgPathArray = svgData[@"svgPaths"];
    BOOL flipInRTL = NO;
    flipInRTL = svgData[@"flipInRtl"];
    if (svgPathArray && [svgPathArray count] != 0)
    {
        [self setImageWith:svgPathArray flipInRTL:flipInRTL];
    }
    else
    {
        [self showUnavailableIcon];
    }
}

- (void)showUnavailableIcon
{
    // we will always show hardcoded square icon as fallback
    NSString *fallbackURLName = @"Square";
    NSString *fallBackURLString = [[NSString alloc] initWithFormat:@"%s%@/%@%ldFilled.json",AdaptiveCards::baseIconCDNUrl, fallbackURLName, fallbackURLName, (long)self.size.width];
    NSURL *svgURL = [[NSURL alloc] initWithString:fallBackURLString];
    __weak ACRSVGImageView *weakSelf = self;
    [self makeIconCDNRequestWithURL:svgURL completion:^(NSDictionary * _Nullable dict, NSError * _Nullable error) {
        ACRSVGImageView *strongSelf = weakSelf;
        if (dict != nil)
        {
            [strongSelf updateImageWithSVGData: dict];
        }
    }];
}

- (void)setImageWith:(NSArray<NSString *> *)pathArray flipInRTL:(BOOL)flipInRTL
{
    NSString *path = [pathArray firstObject];
    NSString *svgXML = [self svgXMLPayloadFrom:path];
    NSData* svgData = [svgXML dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSInputStream *stream = [[NSInputStream alloc] initWithData:svgData];
    SVGKSource *svgSource = [[SVGKSource alloc] initWithInputSteam:stream];
    dispatch_async(dispatch_get_main_queue(), ^{
        SVGKImage *document = [SVGKImage imageWithSource:svgSource];
        UIImage *imageToRender = [self processImage:document.UIImage flipInRTL:flipInRTL];
        self.image = imageToRender;
        if(self.svgImage)
        {
            self.image = self.svgImage;
        }
    });
}

-(UIImage *)processImage:(UIImage *)img flipInRTL:(BOOL)flipInRTL
{
    self.tintColor = self.svgTintColor;
    UIImage *colored = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (_rtl == ACRRtlRTL)
    {
        // flip in right to left mode
        return [colored imageWithHorizontallyFlippedOrientation];
    }
    return colored;
}

- (NSString *)svgXMLPayloadFrom:(NSString *)path
{
    return [[NSString alloc] initWithFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%f\" height=\"%f\" viewBox=\"0 0 %f %f\"><path d=\"%@\"/></svg>", _size.width, _size.height, _size.width, _size.height, path];
}

@end
