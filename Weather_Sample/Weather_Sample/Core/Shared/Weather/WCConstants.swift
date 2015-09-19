//
//  WCConstants.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation


enum WeatherServiceType : Int {
    
    case WeatherServiceTypeByCity = 0
    case WeatherServiceTypeByLocation = 1
    
}

enum WeatherConditions : Int {
    
    case WeatherConditionsClear = 0
    case WeatherConditionsClouds = 1
    case WeatherConditionsRain = 2
    
    func getImageName() -> String? {
        
        switch self {
            
        case .WeatherConditionsClear:
            return "Clear"
            
        case .WeatherConditionsRain:
            return "Rain"
            
        case .WeatherConditionsClouds:
            return "Clouds"
            
        }
    }
    
}