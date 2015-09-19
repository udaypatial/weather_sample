//
//  WSWeatherInfo.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSWeatherInfo: NSObject {
    var locationName = ""
    var temp_min : Float = 0.0
    var temp_max : Float = 0.0
    var temp_avg : Float {
        get {
                return (temp_min + temp_max) / 2.0
        }
    }
    var temp : Float = 0.0
    //stores the weather conditions - rainy, cloudy or clear
    var weatherConditions = WeatherConditions.WeatherConditionsClear
    var forecastDate = NSDate()
    
    var dateString = ""
    var timeString = ""
    
}
