//
//  ETWebServiceConstants.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public enum ETWebServiceMethod : Int8 {
    
    //these constants are used in the sqlwebservice factory to get the corresponding web service class at runtime.
    case ETWebServiceMethodNone = 0
    case ETWebServiceMethodGetWeatherInfo
    case ETWebServiceMethodGetWeatherForecast

    func description() -> String? {
        
        switch self {
            
        case .ETWebServiceMethodGetWeatherInfo:
            return "ETWebServiceMethodGetWeatherInfo"
            
        case .ETWebServiceMethodGetWeatherForecast:
            return "ETWebServiceMethodGetWeatherForecast"
            
        default:
            return nil
        }
    }
}

internal enum ETWebServiceType : Int8 {
    //in future if we have some oracle integration
    case ETWebServiceTypeOracle = 1
    case ETWebServiceTypeSQL = 2
}