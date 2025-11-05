//
//  ACOReference.mm
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 30/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOReference.h"
#import "ACOReferencePrivate.h"
#import "ACOAdaptiveCard.h"
#import "ACOAdaptiveCardPrivate.h"
#import "SharedAdaptiveCard.h"

using namespace AdaptiveCards;

@implementation ACOReference {
    std::shared_ptr<References> _reference;
}

- (instancetype)initWithReference:(const std::shared_ptr<References> &)reference {
    self = [super init];
    if (self && reference) {
        _reference = reference;
    }
    return self;
}

- (ACOReferenceType)type {
    if (!_reference) {
        return ACOReferenceTypeDocument;
    }
    
    ReferenceType cppType = _reference->GetType();
    switch (cppType) {
        case ReferenceType::AdaptiveCard:
            return ACOReferenceTypeAdaptiveCard;
        case ReferenceType::Document:
        default:
            return ACOReferenceTypeDocument;
    }
}

- (NSString *)abstract {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetAbstract().c_str()];
}

- (NSString *)title {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetTitle().c_str()];
}

- (NSString *)url {
    if (!_reference) {
        return @"";
    }
    return [NSString stringWithUTF8String:_reference->GetUrl().c_str()];
}

- (NSString *)icon:(ACRTheme)theme
{
    if (!_reference) {
        return @"";
    }
    ACRCitationIcon icon = ACRCitationIcon(_reference->GetIcon());
    switch (icon)
    {
        // Handling icons independent of theme
        case ACRAdobeIllustrator: return @"adobeIllustrator";
        case ACRAdobePhotoshop: return @"adobePhotoshop";
        case ACRAdobeInDesign: return @"adobeInDesign";
        case ACRMsWord: return @"msword";
        case ACRMsExcel: return @"msExcel";
        case ACRMsPowerPoint: return @"msPowerPoint";
        case ACRMsOneNote: return @"msOneNote";
        case ACRMsSharePoint: return @"msSharePoint";
        case ACRMsVisio: return @"msVisio";
        case ACRMsLoop: return @"msLoop";
        case ACRMsWhiteboard: return @"msWhiteboard";
        case ACRPdf: return @"pdf";
        case ACRSketch: return @"sketch";
        case ACRZip: return @"zip";
        
        // Handling icons based on theme
        case ACRAdobeFlash:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"invalid_light";
                case ACRThemeDark:
                    return @"invalid_dark";
                default:
                    return @"";
            }
        }
        case ACRCode:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"code_light";
                case ACRThemeDark:
                    return @"code_dark";
                default:
                    return @"";
            }
        }
        case ACRGif:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"gif_light";
                case ACRThemeDark:
                    return @"gif_dark";
                default:
                    return @"";
            }
        }
        case ACRCitationImage:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"image_light";
                case ACRThemeDark:
                    return @"image_dark";
                default:
                    return @"";
            }
        }
        case ACRSound:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"sound_light";
                case ACRThemeDark:
                    return @"sound_dark";
                default:
                    return @"";
            }
        }
        case ACRText:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"text_light";
                case ACRThemeDark:
                    return @"text_dark";
                default:
                    return @"";
            }
        }
        case ACRVideo:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return @"video_light";
                case ACRThemeDark:
                    return @"video_dark";
                default:
                    return @"";
            }
        }
        default:
            return @"";
    }
}

- (NSArray<NSString *> *)keywords {
    if (!_reference) {
        return @[];
    }
    
    NSMutableArray<NSString *> *keywordArray = [NSMutableArray array];
    std::vector<std::string> cppKeywords = _reference->GetKeywords();
    
    for (const auto& keyword : cppKeywords) {
        [keywordArray addObject:[NSString stringWithUTF8String:keyword.c_str()]];
    }
    
    return [keywordArray copy];
}

- (ACOAdaptiveCard *)content {
    if (!_reference) {
        return nil;
    }
    
    auto content = _reference->GetContent();
    if (!content) {
        return nil;
    }
    
    ACOAdaptiveCard *acoCard = [[ACOAdaptiveCard alloc] init];
    [acoCard setCard:content];
    return acoCard;
}

- (std::shared_ptr<References>)reference {
    return _reference;
}

@end
