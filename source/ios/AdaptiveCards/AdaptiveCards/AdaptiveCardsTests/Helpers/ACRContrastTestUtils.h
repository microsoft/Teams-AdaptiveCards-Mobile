#import <UIKit/UIKit.h>

static inline CGFloat ACRLinearizedColorComponent(CGFloat component)
{
    return component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4);
}

static inline CGFloat ACRRelativeLuminance(CGFloat red, CGFloat green, CGFloat blue)
{
    return 0.2126 * ACRLinearizedColorComponent(red) +
           0.7152 * ACRLinearizedColorComponent(green) +
           0.0722 * ACRLinearizedColorComponent(blue);
}

static inline CGFloat ACRContrastRatio(UIColor *foregroundColor,
                                       UIColor *backgroundColor,
                                       UITraitCollection *traitCollection)
{
    CGFloat foregroundRed, foregroundGreen, foregroundBlue, foregroundAlpha;
    CGFloat backgroundRed, backgroundGreen, backgroundBlue, backgroundAlpha;
    UIColor *resolvedForeground = [foregroundColor resolvedColorWithTraitCollection:traitCollection];
    UIColor *resolvedBackground = [backgroundColor resolvedColorWithTraitCollection:traitCollection];

    if (![resolvedForeground getRed:&foregroundRed green:&foregroundGreen blue:&foregroundBlue alpha:&foregroundAlpha] ||
        ![resolvedBackground getRed:&backgroundRed green:&backgroundGreen blue:&backgroundBlue alpha:&backgroundAlpha]) {
        return 0;
    }

    foregroundRed = foregroundRed * foregroundAlpha + backgroundRed * (1 - foregroundAlpha);
    foregroundGreen = foregroundGreen * foregroundAlpha + backgroundGreen * (1 - foregroundAlpha);
    foregroundBlue = foregroundBlue * foregroundAlpha + backgroundBlue * (1 - foregroundAlpha);

    CGFloat foregroundLuminance = ACRRelativeLuminance(foregroundRed, foregroundGreen, foregroundBlue);
    CGFloat backgroundLuminance = ACRRelativeLuminance(backgroundRed, backgroundGreen, backgroundBlue);
    CGFloat lighter = MAX(foregroundLuminance, backgroundLuminance);
    CGFloat darker = MIN(foregroundLuminance, backgroundLuminance);
    return (lighter + 0.05) / (darker + 0.05);
}
