//
//  ETDataLibSettingsManager.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public enum ETBuildMode: Int {
    
    case ETBuildModeStaging = 0
    case ETBuildModeProduction = 1
    case ETBuildModeHardcoded = 2
    case ETBuildModeProductionByPass = 3
    case ETBuildModeDevelopment = 4
}

internal enum ETDirectoryPath: Int {
    
    case ETDirectoryPathSettings = 0
    case ETDirectoryPathWebServiceTemplates
    case ETDirectoryPathHardcodedData
}

public class ETDataLibSettingsManager {
    
    internal var rootDirectoryPath: String {
        get {
            return NSBundle.mainBundle().bundlePath + "/AppResources"
        }
    }
    
    public var currentBuildMode: ETBuildMode = .ETBuildModeStaging
    private var plistSettings: NSDictionary = NSDictionary()

    private init() {
        
        //ETSharedLogger.logInfo("ETDataLibSettingsManager init method called")
    }
    
    internal class func sharedInstance() -> ETDataLibSettingsManager! {
        
        struct StaticData {
            
            static var instance: ETDataLibSettingsManager? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&StaticData.onceToken) {
            
            StaticData.instance = ETDataLibSettingsManager()
        }
        return StaticData.instance!
    }
    
    public class func initializeSettingsForMode(mode: ETBuildMode) {
        
        ETDataLibSettingsManager.sharedInstance().currentBuildMode = mode
        
        var settingsFile = ""
        switch mode {
            
        case .ETBuildModeStaging, .ETBuildModeHardcoded:
            settingsFile = "SettingsStaging.plist"
            
            
        case .ETBuildModeProduction, .ETBuildModeProductionByPass:
            settingsFile = "SettingsProduction.plist"
            
        default:
            break
        }
        
        if let directoryPath = ETDataLibSettingsManager.directoryPathFor(.ETDirectoryPathSettings) {
            
            let setttingsFileFullPath = ETDataLibSettingsManager.sharedInstance().rootDirectoryPath + "/" + directoryPath + "/" + settingsFile
            let dictionary = NSDictionary(contentsOfFile: setttingsFileFullPath)
            ETDataLibSettingsManager.sharedInstance().plistSettings = dictionary!
            //ETSharedLogger.logInfo("dictionary : \(setttingsFileFullPath), count : \(dictionary.count)")
        }
    }
    
    internal class func directoryPathFor(directory: ETDirectoryPath) -> String? {
        
        switch directory {
            
        case .ETDirectoryPathWebServiceTemplates:
            return "WebServiceTemplates"
            
        case .ETDirectoryPathSettings:
            return "Settings"
            
        case .ETDirectoryPathHardcodedData:
            return "HardcodedData"
        }
    }
    
    internal class func settingsValueForKey(key: String) -> AnyObject? {
        
        let settingsDic = ETDataLibSettingsManager.sharedInstance().plistSettings
        let encryptedValue = settingsDic.objectForKey(key) as! String
        //add encryption for better security
//        let decryptedValue = ETEncryptionWrapper.decryptDataUsingStringEncryption(encryptedValue, usingKey: kWSHeaderEncryptionKey)
        return encryptedValue
    }
    
    subscript(key: String) -> AnyObject? {
        
        let settingsValue: AnyObject? = ETDataLibSettingsManager.settingsValueForKey(key)
        return settingsValue
    }
}