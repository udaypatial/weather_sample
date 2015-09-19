//
//  ThemeManager.h
//  EServices
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, Theme)
{
    BlackTheme   = 1,
    BlueTheme    = 2
};

@protocol ThemeableDelegate <NSObject>

@required
- (void) applyTheme;

@end

@interface ThemeManager : NSObject

+ (void) registerForThemeChange:(id<ThemeableDelegate>)viewController;
+ (void) unregisterForThemeChange:(id<ThemeableDelegate>)viewController;

+ (BOOL) isValidTheme:(Theme)newTheme;
+ (void) changeTheme:(Theme)theme;

+ (Theme) getCurrentTheme;
+ (Theme) getSavedTheme;

+ (NSString*) getThemeName:(Theme)theme;
+ (UIColor*) getColor:(NSString*)strThemeKey;
+ (UIImage*) getImage:(NSString*)strImageKey;
+ (UIColor*) colorWithHexString:(NSString*)hexString;

+ (UIImage*) imageWithColor:(UIColor*)color;
+ (UIImage*) resizableImage:(UIImage*)image fromInsets:(UIEdgeInsets)insets;

+ (void) clearColorCache;
+ (void) clearImageCache;

+ (void) applyThemeForDefaultButton:(UIButton*)button;
+ (void) applyThemeForActionButton:(UIButton*)button;
+ (void) applyBlueThemeForButton:(UIButton*)button;
+ (void) applyNormalImage:(UIImage*)defaultImg highlightedImage:(UIImage*)highlightedImg disabledImage:(UIImage*)disabledImg forButton:(UIButton*)button;

+ (NSString*) getCurrentThemeFolderPath;
+ (void) applyThemeForTableViewCell:(UITableViewCell*)cell rowIndex:(NSUInteger)row;

@end
