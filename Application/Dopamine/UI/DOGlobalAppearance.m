//
//  GlobalAppearance.m
//  Dopamine
//
//  Created by Lars Fröder on 10.10.23.
//

#import "DOGlobalAppearance.h"
#import <CoreGraphics/CoreGraphics.h>
#import "DOThemeManager.h"

@implementation DOGlobalAppearance

+ (UIImageSymbolConfiguration *)smallIconImageConfiguration
{
    return [UIImageSymbolConfiguration configurationWithPointSize: 14 weight:UIImageSymbolWeightMedium];
}

+ (UIButtonConfiguration *)defaultButtonConfiguration
{
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.imagePadding = 10;
    configuration.baseForegroundColor = [UIColor whiteColor];
    configuration.titleLineBreakMode = NSLineBreakByClipping;

    // IN DARK MODE, APPLE JUST ADDS WHITE WHEN A BUTTON IS HIGHLIGHTED WHEN IT'S SET UP VIA UIButtonConfiguration
    // UNFORTUNATELY THEY FORGOT ABOUT THE POSSIBILITY ABOUT THERE BEING A WHITE BUTTON, SO THOSE JUST DON'T SHOW ANY HIGHLIGHT COLOR
    // HACKY WORKAROUND TO FIX THIS MESS; SCREW APPLE
    configuration.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
        @try {
            NSMutableDictionary<NSAttributedStringKey,id> *textAttributesM = textAttributes ? textAttributes.mutableCopy : [NSMutableDictionary new];
            UIColor *foregroundColor = textAttributes[NSForegroundColorAttributeName];
            if (foregroundColor && [foregroundColor isKindOfClass:[UIColor class]]) {
                CGFloat alpha = 0.0, white = 0.0;
                if ([foregroundColor getWhite:&white alpha:&alpha]) {
                    if ((int)white == 1 && (int)alpha == 1) {
                        CGColorRef cgColor = foregroundColor.CGColor;
                        if (cgColor) {
                            CGColorSpaceRef colorSpace = CGColorGetColorSpace(cgColor);
                            if (colorSpace && CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) {
                                textAttributesM[NSForegroundColorAttributeName] = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
                            }
                        }
                    }
                }
            }
            return textAttributesM;
        }
        @catch (NSException *exception) {
            return textAttributes;
        }
    };
    configuration.imageColorTransformer = ^UIColor * _Nonnull(UIColor * _Nonnull color) {
        @try {
            if (color && [color isKindOfClass:[UIColor class]]) {
                CGFloat alpha = 0.0, white = 0.0;
                if ([color getWhite:&white alpha:&alpha]) {
                    if ((int)white == 1 && (int)alpha == 1) {
                        CGColorRef cgColor = color.CGColor;
                        if (cgColor) {
                            CGColorSpaceRef colorSpace = CGColorGetColorSpace(cgColor);
                            if (colorSpace && CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelRGB) {
                                return [color colorWithAlphaComponent:0.75];
                            }
                        }
                    }
                }
            }
            return color;
        }
        @catch (NSException *exception) {
            return color;
        }
    };
    
    return configuration;
}

+ (UIButtonConfiguration *)defaultButtonConfigurationWithImagePadding:(CGFloat)imagePadding
{
    UIButtonConfiguration *configuration = [DOGlobalAppearance defaultButtonConfiguration];
    configuration.imagePadding = imagePadding;
    return configuration;
}

#pragma mark - Attributed Strings

+ (NSAttributedString*)mainSubtitleString:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName: [UIColor whiteColor],
    }];
}

+ (NSAttributedString*)secondarySubtitleString:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular],
        NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.60],
    }];
}

+ (BOOL)isHomeButtonDevice
{
   return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom == 0;
}

+ (BOOL)isRTL
{
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

+ (BOOL)isSmallDevice
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return window.frame.size.height < SE_PHONE_SIZE_CONST + 50;
}

@end
