//
//  WSFetchWeatherInfoRequest.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSFetchWeatherInfoRequest: ETBaseClientRequest {
    var city = ""
    var latitude = 0.0
    var longitude = 0.0
    //set default web service request type to city
    var weatherServiceType = WeatherServiceType.WeatherServiceTypeByCity
    
}
