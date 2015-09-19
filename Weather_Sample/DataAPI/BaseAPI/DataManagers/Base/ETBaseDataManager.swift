//
//  ETBaseDataManager.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public class ETBaseDataManager {
    
    public typealias ETDataCompletionHandler = (response: ETBaseClientResponse?, error: NSError?) -> Void

    //this methods needs to be override by the subclasses
    class func sharedInstance() -> ETBaseDataManager {
        
        return ETBaseDataManager()
    }
    
    /*
    description : clears the internal data structures which holds the data. You need to call this method, once you are done with accessing the data from datamanager. for ex: in ViewDidDsiappear you can call this method, if you don't need the data no longer. So this will reduce the memory footprint of your app.
    */
    public func clearDataStore() {
        
    }
    
    public func makeSharedInstanceNullable() {
        
    }
    
    internal func processWebServiceResponseFromDataManager(response: ETBaseClientResponse?, request: ETBaseClientRequest, error: NSError?) {
        
        //ETSharedLogger.logInfo("preocessWebServiceResponseFromDataManager: response recieved in data manager for data manipulation")
    }
    
    public func requestData(request: ETBaseClientRequest, completionHandler: ETDataCompletionHandler?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
         
            ETBaseWebService.sendWebServiceRequestFor(request, completionHandler: {(responseObj: ETBaseClientResponse?, errorObj: NSError?) -> Void in
                
                //ETSharedLogger.logInfo("requestData: response recieved in data manager from webservice")
                self.processWebServiceResponseFromDataManager(responseObj, request: request, error: errorObj)
                
                if (completionHandler != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler!(response: responseObj, error: errorObj)
                    })
                }
            })
        }
    }
}
