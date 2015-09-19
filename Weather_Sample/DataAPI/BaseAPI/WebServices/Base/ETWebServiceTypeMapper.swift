//
//  ETWebServiceTypeMapper.swift
//  DataAPI
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

class ETWebServiceTypeMapper {
    
    class func webServiceTypeForWebServiceMethof(method: ETWebServiceMethod) -> ETWebServiceType {
        
        switch method {
            
        default:
            return .ETWebServiceTypeSQL
        }
    }
    
    /**
    can retrieve the corresponding web service factory class for a given web service type
    
    - parameter type: web service type. whether its SQL or Oracle etc.
    - returns: ETBaseWebServiceFactory object for the ETWebServiceType
    */
    class func getWebServiceFactoryForWSType(type: ETWebServiceType) -> ETBaseWebServiceFactory {
        
        switch type {
            
        case .ETWebServiceTypeSQL:
            return ETSQLWebServiceFactory()
            
        case .ETWebServiceTypeOracle:
            return ETOracleWebServiceFactory()
        }
    }
}