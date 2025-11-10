//
//  ACRCustomImageResolver.mm
//  ADCIOSVisualizer
//
//  Created by Harika P on 10/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRCustomImageResolver.h"

@implementation ACRCustomImageResolver

- (UIImage *)getImageForCitation:(ACRCitationIcon)iconName withTheme:(ACRTheme)theme {
    switch (iconName)
    {
        // Handling icons independent of theme
        case ACRAdobeIllustrator: return [UIImage imageNamed: @"adobeIllustrator"];
        case ACRAdobePhotoshop: return [UIImage imageNamed: @"adobePhotoshop"];
        case ACRAdobeInDesign: return [UIImage imageNamed: @"adobeInDesign"];
        case ACRMsWord: return [UIImage imageNamed: @"msword"];
        case ACRMsExcel: return [UIImage imageNamed: @"msExcel"];
        case ACRMsPowerPoint: return [UIImage imageNamed: @"msPowerPoint"];
        case ACRMsOneNote: return [UIImage imageNamed: @"msOneNote"];
        case ACRMsSharePoint: return [UIImage imageNamed: @"msSharePoint"];
        case ACRMsVisio: return [UIImage imageNamed: @"msVisio"];
        case ACRMsLoop: return [UIImage imageNamed: @"msLoop"];
        case ACRMsWhiteboard: return [UIImage imageNamed: @"msWhiteboard"];
        case ACRPdf: return [UIImage imageNamed: @"pdf"];
        case ACRSketch: return [UIImage imageNamed: @"sketch"];
        case ACRZip: return [UIImage imageNamed: @"zip"];
        
        // Handling icons based on theme
        case ACRAdobeFlash:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"invalid_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"invalid_dark"];
                default:
                    return nil;
            }
        }
        case ACRCode:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"code_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"code_dark"];
                default:
                    return nil;
            }
        }
        case ACRGif:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"gif_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"gif_dark"];
                default:
                    return nil;
            }
        }
        case ACRCitationImage:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"image_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"image_dark"];
                default:
                    return nil;
            }
        }
        case ACRSound:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"sound_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"sound_dark"];
                default:
                    return nil;
            }
        }
        case ACRText:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"text_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"text_dark"];
                default:
                    return nil;
            }
        }
        case ACRVideo:
        {
            switch (theme)
            {
                case ACRThemeLight:
                    return [UIImage imageNamed: @"video_light"];
                case ACRThemeDark:
                    return [UIImage imageNamed: @"video_dark"];
                default:
                    return nil;
            }
        }
        default:
            return nil;
    }
}

@end
