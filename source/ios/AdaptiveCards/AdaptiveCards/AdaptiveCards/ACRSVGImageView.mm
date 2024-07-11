//
//  ACRSVGImageView.m
//  AdaptiveCards
//
//  Created by Abhishek on 26/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRSVGImageView.h"
#import "Icon.h"
#import "ACRErrors.h"
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
    BOOL _isFilled;
}

- (instancetype)init:(NSString *)iconURL
                 rtl:(ACRRtl)rtl
            isFilled:(BOOL)isFilled
                size:(CGSize)size
           tintColor:(UIColor *)tintColor;
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self)
    {
        _svgPayloadURL = iconURL;
        self.size = size;
        _rtl = rtl;
        _isFilled = isFilled;
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
            BOOL success = [strongSelf updateImageWithSVGData: dict];
            if (!success)
            {
                [strongSelf showUnavailableIcon];
            }
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
        NSError *error = [NSError errorWithDomain:ACRParseErrorDomain
                                                  code:ACRInputErrorValueMissing
                                              userInfo:nil];
        completion(nil, error);
    }
}

- (void)showUnavailableIcon
{
    // we will always show hardcoded square icon as fallback
    NSString *fallbackURLName = @"Square";
    NSString *fallBackURLString = [[NSString alloc] initWithFormat:@"%s%@/%@.json",AdaptiveCards::baseIconCDNUrl, fallbackURLName, fallbackURLName];
    NSURL *svgURL = [[NSURL alloc] initWithString:fallBackURLString];
    [self makeIconCDNRequestWithURL:svgURL completion:^(NSDictionary * _Nullable dict, NSError * _Nullable error) {
        if (dict != nil)
        {
            [self updateImageWithSVGData:dict iconFilledStyleKey:@"filled"];
        }
    }];
}

- (void)setImageWith:(NSArray<NSString *> *)pathArray flipInRTL:(BOOL)flipInRTL viewPort:(CGFloat)viewPort
{
    NSString *path = [pathArray firstObject];
    NSString *svgXML = [self svgXMLPayloadFrom:path viewPort: viewPort];
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
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    if (_rtl == ACRRtlRTL)
    {
        // flip in right to left mode
        return [colored imageWithHorizontallyFlippedOrientation];
    }
    return colored;
}

- (NSString *)svgXMLPayloadFrom:(NSString *)path viewPort:(CGFloat)viewPort
{
    return [[NSString alloc] initWithFormat:@"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"%f\" height=\"%f\" viewBox=\"0 0 %f %f\"><path d=\"%@\"/></svg>", _size.width, _size.height, viewPort, viewPort, path];
}

- (BOOL)updateImageWithSVGData:(NSDictionary *)svgData
{
    NSString *iconFilledStyleKey = _isFilled ? @"filled" : @"regular";
    return [self updateImageWithSVGData:svgData iconFilledStyleKey:iconFilledStyleKey];
}

- (BOOL)updateImageWithSVGData:(NSDictionary *)svgData iconFilledStyleKey:(NSString *)iconFilledStyleKey
{
    NSDictionary *iconDict = svgData[iconFilledStyleKey];
    if (iconDict)
    {
        // exact size for icon may not be available, try to find closest size of icon which is available
        NSString *targetKey = [self findClosestIconSizeInArray:[iconDict allKeys] toTarget:@(self.size.height)];
        NSArray<NSString *> *pathArray = iconDict[targetKey];
        if (pathArray != nil)
        {
            BOOL flipInRTL = NO;
            flipInRTL = svgData[@"flipInRtl"];
            [self setImageWith:pathArray flipInRTL:flipInRTL viewPort:[targetKey doubleValue]];
            return YES;
        }
    }
    return NO;
}

- (NSString *)findClosestIconSizeInArray:(NSArray<NSString *> *)numbers toTarget:(NSNumber *)targetNumber
{
    if (numbers.count == 0)
    {
        return nil;
    }

    NSString *closestNumberString = numbers[0];
    NSNumber *closestNumber = @([closestNumberString doubleValue]);
    double closestDifference = fabs([closestNumber doubleValue] - [targetNumber doubleValue]);

    for (NSString *numberString in numbers)
    {
        NSNumber *number = @([numberString doubleValue]);
        double currentDifference = fabs([number doubleValue] - [targetNumber doubleValue]);
        if (currentDifference < closestDifference)
        {
            closestDifference = currentDifference;
            closestNumberString = numberString;
        }
    }
    return closestNumberString;
}

@end
