//
//  ETBaseSOAPService.swift
//  DataAPI
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

class ETBaseJSONWebService : ETBaseWebService {
    
    var jsonResult: AnyObject?
    let kDateFormatter = "yyyy-MM-dd'T'HH:mm:ss"
    let kShortDateFormatter = "MM/dd/yyyy"
    let kShortTimeFormatter = "hh:mmZ"
    
    override func processWebResponse(strResponse: String) {
        parseJsonResponse(strResponse)
    }
    
    func parseJsonResponse(jsonString: String) {
        
        let jsonData: NSData? = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableLeaves) as AnyObject?
        } catch {
            ETSharedLogger.logError("An Error Occurred in parseJsonResponse : \(error)")
        }
        
        if jsonResult == nil {
            ETSharedLogger.logError("jsonDictionary is nil")
        }
    }
}

    