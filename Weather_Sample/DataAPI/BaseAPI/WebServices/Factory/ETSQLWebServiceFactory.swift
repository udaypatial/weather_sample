//
//  ETSQLWebServiceFactory.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

internal class ETSQLWebServiceFactory : ETBaseWebServiceFactory  {
    
    override func webServiceFor(method: ETWebServiceMethod) -> ETBaseWebService? {
        
        switch method {
        
        case .ETWebServiceMethodGetWeatherInfo:
            return WSFetchWeatherInfoService()
            
        case .ETWebServiceMethodGetWeatherForecast:
            return WSGetWeatherForecastService()
            
        default:
            ETSharedLogger.logError("No webservice \(method.description()) defined in the ETSQLWebServiceFactory class. Please define.")
            return nil
        }
    }
}