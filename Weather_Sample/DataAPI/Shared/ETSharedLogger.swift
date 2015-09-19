//
//  ETSharedLogger.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public class ETSharedLogger {
    
    public class func logVerbose(message: String) {
        
        if !ETSharedLogger.isLogEnabled() {
             return
        }
        print(message)
    }
    
    public class func logError(message: String) {
        
        if !ETSharedLogger.isLogEnabled() {
            return
        }
        print("*********** Error *********** : \(message)")
    }
    
    public class func logInfo(message: String) {

        if !ETSharedLogger.isLogEnabled() {
            return
        }
        print(message)
    }
    
    public class func isLogEnabled() -> Bool {
        return false
    }
}
