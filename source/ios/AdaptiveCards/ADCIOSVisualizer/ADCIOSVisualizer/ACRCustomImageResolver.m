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

- (UIImage *)getImage:(ACIcon)iconName withTheme:(ACRTheme)theme {
    switch (iconName)
    {
        // Handling icons independent of theme
        case ACIconAdobeIllustrator: return [UIImage imageNamed: @"adobeIllustrator"];
        case ACIconAdobePhotoshop: return [UIImage imageNamed: @"adobePhotoshop"];
        case ACIconAdobeInDesign: return [UIImage imageNamed: @"adobeInDesign"];
        case ACIconMsWord: return [UIImage imageNamed: @"msword"];
        case ACIconMsExcel: return [UIImage imageNamed: @"msExcel"];
        case ACIconMsPowerPoint: return [UIImage imageNamed: @"msPowerPoint"];
        case ACIconMsOneNote: return [UIImage imageNamed: @"msOneNote"];
        case ACIconMsSharePoint: return [UIImage imageNamed: @"msSharePoint"];
        case ACIconMsVisio: return [UIImage imageNamed: @"msVisio"];
        case ACIconMsLoop: return [UIImage imageNamed: @"msLoop"];
        case ACIconMsWhiteboard: return [UIImage imageNamed: @"msWhiteboard"];
        case ACIconPdf: return [UIImage imageNamed: @"pdf"];
        case ACIconSketch: return [UIImage imageNamed: @"sketch"];
        case ACIconZip: return [UIImage imageNamed: @"zip"];
        
        // Handling icons based on theme
        case ACIconAdobeFlash:
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
        case ACIconCode:
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
        case ACIconGif:
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
        case ACIconCitationImage:
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
        case ACIconSound:
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
        case ACIconText:
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
        case ACIconVideo:
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
