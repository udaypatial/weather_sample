//
//  ThemeManager.m
//  EServices
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

#import "ThemeManager.h"
#import "ThemeConstants.h"

@interface ThemeManager() //class extension

+ (void) customizeAppearance;
+ (void) loadTheme:(Theme)theme;
+ (UIColor*) colorWithHexString:(NSString*)hexString;
+ (CGFloat) colorComponentFrom:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length;

@end

@implementation ThemeManager

static NSMutableDictionary *currentColorDictionary = nil;
static NSMutableDictionary *currentActualColorDictionary = nil;
static NSMutableDictionary *currentActualImageDictionary = nil;
static NSMutableArray *targets = nil;

static Theme currentTheme = BlackTheme;
static NSString *currentThemeName = nil;
static NSString *currentThemeFolderPath = nil;
static BOOL isRetinaDisplay = FALSE;

+ (void) initialize //This initialize method is calling once during the life time
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
    {
        isRetinaDisplay = TRUE;
    }
    
    currentActualColorDictionary = [NSMutableDictionary new];
    currentActualImageDictionary = [NSMutableDictionary new];
    targets = [NSMutableArray new];
    
    currentTheme = [ThemeManager getSavedTheme];
    [ThemeManager loadTheme:currentTheme];
}

+ (NSString*) getCurrentThemeFolderPath
{
    return currentThemeFolderPath;
}

+ (void) loadTheme:(Theme)theme
{
    [currentActualColorDictionary  removeAllObjects];
    [currentActualImageDictionary removeAllObjects];
    [currentColorDictionary removeAllObjects];
    
    NSString *themePath = nil;
    switch (theme)
    {
        case BlueTheme:
            themePath = @"AppResources/Themes/Blue";
            break;
            
        case BlackTheme:
            themePath = @"AppResources/Themes/Black";
            break;
            
        default:
            break;
    }
    if(themePath)
    {
        NSString *fullThemePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:themePath];
        currentColorDictionary = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:[fullThemePath stringByAppendingPathComponent:@"Colors.plist"]]];
        
        currentTheme = theme;
        currentThemeName = [ThemeManager getThemeName:theme];
        currentThemeFolderPath = [fullThemePath stringByAppendingPathComponent:@"Images"];
        //[ThemeManager customizeAppearance];
    }
}

+ (Theme) getSavedTheme
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNumber *numTheme = [[NSUserDefaults standardUserDefaults] objectForKey:@"theme_preference"];
    Theme theme = [numTheme integerValue];
    //DDLogInfo(@"Saved Theme : %@", [ThemeManager getThemeName:theme]);
    if([ThemeManager isValidTheme:theme]) return theme;
    return BlueTheme;
}

+ (Theme) getCurrentTheme
{
    return currentTheme;
}

+ (UIColor*) getColor:(NSString*)strThemeKey
{
    if(strThemeKey == nil) return [UIColor blackColor];
    UIColor *resultColor = currentActualColorDictionary[strThemeKey];
    if(resultColor == nil)
    {
        NSString *strHexColor = (NSString*) currentColorDictionary[strThemeKey];
        UIColor *color = [ThemeManager colorWithHexString:strHexColor];
        if(color)
        {
            currentActualColorDictionary[strThemeKey] = color;
            return color;
        }
        
        NSLog(@"$$$$$$$$$ no color code for the : %@", strThemeKey);
        return [UIColor blackColor];
    }
    return resultColor;
}

+ (void) registerForThemeChange:(id<ThemeableDelegate>)viewController
{
    if(viewController)
    {
        [targets addObject:viewController];
    }
}

+ (void) unregisterForThemeChange:(id<ThemeableDelegate>)viewController
{
    if(viewController)
    {
        [targets removeObject:viewController];
    }
}

+ (BOOL) isValidTheme:(Theme)newTheme
{
    for(Theme theme = BlackTheme; theme <= BlueTheme; theme++)
    {
        if(theme == newTheme) return TRUE;
    }
    return FALSE;
}

+ (void) changeTheme:(Theme)theme
{
    if([ThemeManager isValidTheme:theme])
    {
        [ThemeManager loadTheme:theme];
        
        for(id<ThemeableDelegate> viewController in targets)
        {
            [viewController applyTheme];
        }
    }
}

+ (UIColor*) colorWithHexString:(NSString*)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha = 1, red = 0, blue = 0, green = 0;
    switch ([colorString length])
    {
        case 3:// #RGB
            alpha = 1.0f;
            red   = [ThemeManager colorComponentFrom:colorString start:0 length:1];
            green = [ThemeManager colorComponentFrom:colorString start:1 length:1];
            blue  = [ThemeManager colorComponentFrom:colorString start:2 length:1];
            break;
            
        case 4:// #ARGB
            alpha = [ThemeManager colorComponentFrom:colorString start:0 length:1];
            red   = [ThemeManager colorComponentFrom:colorString start:1 length:1];
            green = [ThemeManager colorComponentFrom:colorString start:2 length:1];
            blue  = [ThemeManager colorComponentFrom:colorString start:3 length:1];
            break;
            
        case 6:// #RRGGBB
            alpha = 1.0f;
            red   = [ThemeManager colorComponentFrom:colorString start:0 length:2];
            green = [ThemeManager colorComponentFrom:colorString start:2 length:2];
            blue  = [ThemeManager colorComponentFrom:colorString start:4 length:2];
            break;
            
        case 8:// #AARRGGBB
            alpha = [ThemeManager colorComponentFrom:colorString start:0 length:2];
            red   = [ThemeManager colorComponentFrom:colorString start:2 length:2];
            green = [ThemeManager colorComponentFrom:colorString start:4 length:2];
            blue  = [ThemeManager colorComponentFrom:colorString start:6 length:2];
            break;
            
        default:
            return [UIColor greenColor];
            //[NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            //break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat) colorComponentFrom:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring :[NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return (hexComponent / 255.0);
}

+ (NSString*) getThemeName:(Theme)theme
{
    switch (theme)
    {
        case BlackTheme:
            return @"Black";
            
        case BlueTheme:
            return @"Blue";
            
        default:
            return nil;
    }
}

+ (UIImage*) getImage:(NSString*)strImageKey
{
    BOOL isIphone = FALSE;
    NSString *filePathiPhone = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        filePathiPhone = [NSString stringWithFormat:@"%@/%@-iPhone@2x.png", currentThemeFolderPath, strImageKey];
        isIphone = TRUE;
    }
    UIImage *resultImage = currentActualImageDictionary[strImageKey];
    if(resultImage == nil)
    {
        UIImage *image = nil;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@@2x.png", currentThemeFolderPath, strImageKey];
        if(isIphone && [fileManager fileExistsAtPath:filePathiPhone])
        {
            image = [UIImage imageWithContentsOfFile:filePathiPhone];
        }
        else if(isIphone && [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@-iPhone.png", currentThemeFolderPath, strImageKey]])
        {
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@-iPhone.png", currentThemeFolderPath, strImageKey]];;
        }
        else if([fileManager fileExistsAtPath:filePath] && isRetinaDisplay)
        {
            image = [UIImage imageWithContentsOfFile:filePath];
        }
        else
        {
            filePath = [NSString stringWithFormat:@"%@/%@.png", currentThemeFolderPath, strImageKey];
            if([fileManager fileExistsAtPath:filePath])
            {
                image = [UIImage imageWithContentsOfFile:filePath];
            }
        }
        if(image)
        {
            currentActualImageDictionary[strImageKey] = image;
        }
        return image;
    }
    return resultImage;
}

+ (void) customizeAppearance
{
    UIImage *navBarImage = [ThemeManager getImage:@"NavigationBarBg"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    //for bar button < symbol etc
    UIColor *barButtonBackSymbolColor = [ThemeManager getColor:@"NAVIGATIONBAR_BAR_BUTTON_TEXT_COLOR"];
    [[UIView appearance] setTintColor:barButtonBackSymbolColor];

    //for bar button text colors
    UIColor *barButtonTextColor = [ThemeManager getColor:@"NAVIGATIONBAR_BAR_BUTTON_TEXT_COLOR"];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColor} forState:UIControlStateDisabled];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColor} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColor} forState:UIControlStateHighlighted];
    
    //UIPopoverController customization
    UIColor *barButtonTextColorInPopOver = [ThemeManager getColor:@"NAVIGATIONBAR_BAR_BACK_SYMBOL_COLOR"];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColorInPopOver} forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColorInPopOver} forState:UIControlStateDisabled];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : barButtonTextColorInPopOver} forState:UIControlStateHighlighted];

}

+ (void) applyThemeForDefaultButton:(UIButton*)button
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *defaultImage = [ThemeManager getImage:KThemeDefaultButtonImage];
    defaultImage = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:defaultImage forState:UIControlStateNormal];
    [button setTitleColor:[ThemeManager getColor:@"DEFAULT_BUTTON_TEXT_COLOR"] forState:UIControlStateNormal];
    
    UIImage *selectedImage = [ThemeManager getImage:KThemeDefaultButtonSelectedImage];
    selectedImage = [selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    
    UIImage *disabledImage = [ThemeManager getImage:KThemeDefaultButtonDisabledImage];
    disabledImage = [disabledImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    [button setTitleColor:[ThemeManager getColor:@"DEFAULT_BUTTON_TEXT_DISABLED_COLOR"] forState:UIControlStateDisabled];
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
}

+ (void) applyThemeForActionButton:(UIButton*)button
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *defaultImage = [ThemeManager getImage:@"ButtonAction"];
    defaultImage = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:defaultImage forState:UIControlStateNormal];
    
    UIImage *selectedImage = [ThemeManager getImage:@"ButtonActionSelected"];
    selectedImage = [selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    
    UIImage *disabledImage = [ThemeManager getImage:@"ButtonDisabled"];
    disabledImage = [disabledImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    [button setTitleColor:[ThemeManager getColor:@"ACTION_BUTTON_TEXT_COLOR"] forState:UIControlStateNormal];
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
}

+ (void) applyBlueThemeForButton:(UIButton*)button
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *defaultImage = [ThemeManager getImage:@"ButtonBlue"];
    defaultImage = [defaultImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
    [button setBackgroundImage:defaultImage forState:UIControlStateNormal];
    
    UIImage *selectedImage = [ThemeManager getImage:@"ButtonBlueSelected"];
    selectedImage = [selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    
    UIImage *disabledImage = [ThemeManager getImage:@"ButtonBlueDisabled"];
    disabledImage = [disabledImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
}

+ (UIImage*) resizableImage:(UIImage*)image fromInsets:(UIEdgeInsets)insets
{
    UIImage *result = [image resizableImageWithCapInsets:insets];
    return result;
}

+ (void) applyNormalImage:(UIImage*)defaultImg highlightedImage:(UIImage*)highlightedImg disabledImage:(UIImage*)disabledImg forButton:(UIButton*)button
{
    [button setBackgroundImage:defaultImg forState:UIControlStateNormal];
    [button setBackgroundImage:disabledImg forState:UIControlStateDisabled];
    [button setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
}

+ (void) clearImageCache
{
    [currentActualImageDictionary removeAllObjects];
}

+ (void) clearColorCache
{
    [currentColorDictionary removeAllObjects];
    [currentActualColorDictionary removeAllObjects];
}

+ (void) applyThemeForTableViewCell:(UITableViewCell*)cell rowIndex:(NSUInteger)row
{
    UIColor *color = nil;
    switch (row % 2)
    {
        case 1:
            color = [ThemeManager getColor:KTableEvenColor];
            break;
            
        case 0:
            color = [ThemeManager getColor:KTableOddColor];
            break;
            
        default:
            break;
    }
    if(cell.backgroundView == nil)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView = bgView;
    }
    cell.backgroundView.backgroundColor = color;
    
    static NSUInteger TAG_CELL = 100;
    if(cell.selectedBackgroundView.tag != TAG_CELL)
    {
        UIView *selectedView = [[UIView alloc] init];
        selectedView.tag = TAG_CELL;
        selectedView.backgroundColor = [ThemeManager getColor:@"TABLE_SELECTED_COLOR"];
        cell.selectedBackgroundView = selectedView;
    }
    if([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

+ (UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
