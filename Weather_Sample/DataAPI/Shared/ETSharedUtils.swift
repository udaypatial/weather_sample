//
//  ETSharedUtils.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation
//import SystemConfiguration
import Darwin
import Security

public extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

public extension NSDate {
    
    public class func dateFromString(strDate: String, formatter strFormatter: String) -> NSDate? {
        
        struct StaticData {
            
            static var onceToken: dispatch_once_t = 0
            static var dateFormatter: NSDateFormatter? = nil
        }
        
        dispatch_once(&StaticData.onceToken) {
            
            StaticData.dateFormatter = NSDateFormatter()
            StaticData.dateFormatter!.locale = NSLocale(localeIdentifier: "en_us")
            //StaticData.dateFormatter!.timeZone = NSTimeZone(abbreviation: "GMT")
        }
        StaticData.dateFormatter!.dateFormat = strFormatter
        let result = StaticData.dateFormatter!.dateFromString(strDate)
        
        if result == nil {
            ETSharedLogger.logError("invalid dateFromString : \(strDate)")
        }
        return result
    }
    
    public class func stringFromDate(date: NSDate, formatter strFormatter: String) -> String? {
        
        struct StaticData {
            
            static var onceToken: dispatch_once_t = 0
            static var dateFormatter: NSDateFormatter? = nil
        }
        
        dispatch_once(&StaticData.onceToken) {
            
            StaticData.dateFormatter = NSDateFormatter()
            StaticData.dateFormatter!.locale = NSLocale(localeIdentifier: "en_us")
            //StaticData.dateFormatter!.timeZone = NSTimeZone(abbreviation: "GMT")
        }
        StaticData.dateFormatter!.dateFormat = strFormatter
        let result = StaticData.dateFormatter!.stringFromDate(date)
        return result
    }
    
    public class func daysFrom(date:NSDate, toDate:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.NSDayCalendarUnit, fromDate: date, toDate: toDate, options: []).day
    }
}

public class ETSharedUtils {
    
    public class func stringForValue(value: Double) -> String {
        
        struct StaticData {
            
            static var formatter: NSNumberFormatter? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&StaticData.onceToken) {
            
            let formatter = NSNumberFormatter()
            //formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            //formatter.formatterBehavior = NSNumberFormatterBehavior.BehaviorDefault
            //formatter.usesGroupingSeparator = true
            formatter.positiveFormat = "###,##0.00"
            formatter.locale = NSLocale(localeIdentifier: "en-us") // to avoid arabic text in the ui
            StaticData.formatter = formatter
        }
        return StaticData.formatter!.stringFromNumber(value)!
    }
    
    public class func doubleForString(value: String) -> Double {
        
        return 0
    }
    
    public class func urlEncodedValue(value: String) -> String? {
        
        if value.isEmpty {
            return nil
        }
        let escapedString = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        return escapedString
    }

    public class func trimString(value: String) -> String {
        
        return value.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    public class func documentsDirectoryPath() -> String {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0]
        return documentsPath
    }
    
    public class func cachesDirectoryPath() -> String {
        
        let cachesPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[1]
        return cachesPath
    }
    
    public class func isConnectedToInternet() -> Bool {
        
        
        /*
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        var isConnected = (isReachable && !needsConnection) ? true : false
        if isConnected {
            ETSharedLogger.logInfo("Connected to internet")
        } else {
            ETSharedLogger.logError("Not Connected to internet")
        }
        return isConnected
        */
        return true
    }
    
    public class func applicationVersionNumber() -> String {
    
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        return version
    }
    
    public class func applicationBuildNumber() -> String {
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let buildNumber = nsObject as! String
        return buildNumber
    }
    
    public class func getAES128EncryptedMessage(plainText: String?, key: String?) -> String? {
        return ""
    }
    
    public class func isValidEmail(strEmail: String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = predicate.evaluateWithObject(strEmail)
        return result
    }
    
    public class func URLDecodedString(strValue: String) -> String? {
        let result =  strValue.stringByReplacingOccurrencesOfString("+", withString: "")
        let resultString = result.stringByRemovingPercentEncoding
        return resultString
    }
    
    ///returns an url appended by the timestamp at the end. This can be used for removing server cache.
    class func urlByAppendedQueryParameter(baseUrl: String) -> String {
        let finalURL = baseUrl + "?timestamp=" + String(format: "%.0f", NSDate().timeIntervalSinceReferenceDate)
        ETSharedLogger.logInfo("final url : \(finalURL)")
        return finalURL
    }
}
