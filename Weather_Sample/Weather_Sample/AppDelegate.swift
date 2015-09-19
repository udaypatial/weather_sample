//
//  AppDelegate.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //getting the build mode from the info-plist file. (based on the staging/dev or production target)
        let buidModeNumber = NSBundle.mainBundle().infoDictionary!["BuildMode"] as! NSNumber?
        let buildMode = ETBuildMode(rawValue: buidModeNumber!.integerValue)!
        
        //initialize the datalib settings manager for the build mode. URL's and other settings will be loaded based on the build mode - for dev/production
        ETDataLibSettingsManager.initializeSettingsForMode(buildMode)
        
        return true
    }
    
    //set the initial theme using theme manager
    private func applyApplicationTheme() {
        
        ///set the ui navigation bar background color
        UINavigationBar.appearance().barTintColor = ThemeManager.getColor("NAVIGATIONBAR_BAR_TINT_COLOR")
        
        let appColor = UIColor.whiteColor()
        /// set the back button text and arrow color
        UINavigationBar.appearance().tintColor = appColor
        UITextField.appearance().tintColor = appColor
        UITextView.appearance().tintColor = appColor
        
        ///set the ui navigation bar title color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : ThemeManager.getColor("NAVIGATIONBAR_BAR_BUTTON_COLOR")]
        //self.window!.tintColor = ThemeManager.getColor("NAVIGATIONBAR_BAR_BUTTON_COLOR")
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    // MARK: - Core Data stack

    

}

