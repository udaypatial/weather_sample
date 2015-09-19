//
//  WSFetchWeatherInfoService.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSFetchWeatherInfoService: WSBaseWebService {
    private var request: WSFetchWeatherInfoRequest?
    private var weatherResponse = WSFetchWeatherInfoResponse()
    
    override init() {
        super.init()
        
        httpMethod = .ETHTTPWebMethodPost
        shouldLogResponse = false
        responseData = weatherResponse
    }
    
    override func setProperties() {
        request = requestData as? WSFetchWeatherInfoRequest
        //based on the webservice type call for city or location
        switch request!.weatherServiceType {
        case .WeatherServiceTypeByCity:
            webServiceURL = webServiceURL! + "/weather?q=\(request!.city)&units=metric"
        case .WeatherServiceTypeByLocation:
            webServiceURL = webServiceURL! + "/weather?lat=\(request!.latitude)&lon=\(request!.longitude)&units=metric"
        }
        
        super.setProperties()
    }
    
    override func parseJsonResponse(jsonString: String) {
        super.parseJsonResponse(jsonString)
        let weatherInfoDictionary = jsonResult as! NSDictionary?
        if let weatherDict = weatherInfoDictionary {
            
            let weatherInfo = self.parseWeatherInfoFromJSONDictionary(weatherDict, jsonString: jsonString)
            weatherResponse.weatherInfoResponse = weatherInfo
            weatherResponse.responseStatus = .ETBaseResponseStatusSuccess
        }
        else
        {
            //check for the offline cached data
            let cityName = request?.city
            let cacheJSONString = RCCoreDataManager.sharedInstance().getWeatherInfoJSON(cityName!)
            if cacheJSONString.characters.count > 0 {
                
                super.parseJsonResponse(cacheJSONString)
                let weatherInfoDictionary = jsonResult as! NSDictionary?
                
                if let weatherDict = weatherInfoDictionary {
                    
                    let weatherInfo = self.parseWeatherInfoFromJSONDictionary(weatherDict, jsonString: jsonString)
                    weatherResponse.weatherInfoResponse = weatherInfo
                    
                    weatherResponse.responseStatus = .ETBaseResponseStatusSuccess
                }
                
            }
        }
    }
    
    private func parseWeatherInfoFromJSONDictionary(jsonDataDictionary: NSDictionary, jsonString:String) -> WSWeatherInfo {
        
        let newWeatherInfo = WSWeatherInfo()
        newWeatherInfo.locationName = jsonDataDictionary["name"] as! String
        
        //save the same to coredata
        if jsonString.characters.count > 0 {
            RCCoreDataManager.sharedInstance().saveorUpdateCityWeather(newWeatherInfo.locationName.lowercaseString, currentJSON: jsonString)
        }
        
        //parse the weather details
        let jsonTemperatureDict = jsonDataDictionary["main"] as! NSDictionary
        newWeatherInfo.temp_min = jsonTemperatureDict["temp_min"] as! Float
        newWeatherInfo.temp_max = jsonTemperatureDict["temp_max"] as! Float
        newWeatherInfo.temp = jsonTemperatureDict["temp"] as! Float
        
        let weatherArray = jsonDataDictionary["weather"] as! NSArray
        if weatherArray.count > 0 {
            let weatherConditionsDict = weatherArray[0] as! NSDictionary
            let weatherCondString = weatherConditionsDict["main"] as! String
            
            //assign the weather conditions for icon selection
            switch weatherCondString {
            case "Clear":
                newWeatherInfo.weatherConditions = .WeatherConditionsClear
            case "Rain":
                newWeatherInfo.weatherConditions = .WeatherConditionsRain
            case "Clouds":
                newWeatherInfo.weatherConditions = .WeatherConditionsClouds
            default:
                break
            }
        }
        
        return newWeatherInfo
        
    }
    
}
