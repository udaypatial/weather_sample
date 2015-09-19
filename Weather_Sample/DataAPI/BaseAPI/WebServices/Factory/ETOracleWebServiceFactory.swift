//
//  ETOracleWebServiceFactory.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

internal class ETOracleWebServiceFactory : ETBaseWebServiceFactory {
    
    override func webServiceFor(method: ETWebServiceMethod) -> ETBaseWebService? {
        
        switch method {
            
        default:
            ETSharedLogger.logError("No webservice \(method.description()) defined in the ETOracleWebServiceFactory class. Please define.")
            return nil
        }
    }
}