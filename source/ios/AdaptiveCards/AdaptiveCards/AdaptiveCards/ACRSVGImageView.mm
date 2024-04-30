//
//  ACRSVGImageView.m
//  AdaptiveCards
//
//  Created by Abhishek on 26/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRSVGImageView.h"
#import <SVGKit/SVGKit.h>

@implementation ACRSVGImageView
{
    NSString *_svgPayloadURL;
    CGSize _size;
    ACRRtl _rtl;
    UIColor *_tintColor;
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
        _size = size;
        _rtl = rtl;
        _tintColor = tintColor;
        [self loadIconFromCDN];
    }
    return self;
}

- (void)loadIconFromCDN
{
    NSURL *url = [[NSURL alloc] initWithString:_svgPayloadURL];
    if (url)
    {
        __weak ACRSVGImageView *weakSelf = self;
        NSURLSessionDataTask *iconDataTask = [[NSURLSession sharedSession]
                                              dataTaskWithURL:url
                                              completionHandler:^(NSData * _Nullable data,
                                                                  NSURLResponse * _Nullable response,
                                                                  NSError * _Nullable error) {
            ACRSVGImageView *strongSelf = weakSelf;
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
                       [strongSelf showUnavailableIcon];
                   }
                   else
                   {
                       NSArray<NSString *> *svgPathArray = dict[@"svgPaths"];
                       BOOL flipInRTL = NO;
                       flipInRTL = dict[@"flipInRtl"];
                       if (svgPathArray && [svgPathArray count] != 0)
                       {
                           [strongSelf setImageWith:svgPathArray flipInRTL:flipInRTL];
                       }
                       else 
                       {
                           [strongSelf showUnavailableIcon];
                       }
                   }
            }
            else
            {
                [strongSelf showUnavailableIcon];
            }
        }];
        [iconDataTask resume];
    }
    else 
    {
        [self showUnavailableIcon];
    }
    
}

- (void)showUnavailableIcon
{
    //TODO: Bundle Unavailable Icon with SDK and show here
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
    });
}

-(UIImage *)processImage:(UIImage *)img flipInRTL:(BOOL)flipInRTL
{
    self.tintColor = _tintColor;
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
