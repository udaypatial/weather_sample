//
//  WSGetWeatherForecastService.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSGetWeatherForecastService: WSBaseWebService {
    private var request: WSGetWeatherForecastRequest?
    private var weatherResponse = WSGetWeatherForecastResponse()
    
    override init() {
        
        super.init()
        
        httpMethod = .ETHTTPWebMethodPost
        shouldLogResponse = false
        responseData = weatherResponse
    }
    
    override func setProperties() {
        request = requestData as? WSGetWeatherForecastRequest
        switch request!.weatherServiceType {
        case .WeatherServiceTypeByCity:
            webServiceURL = webServiceURL! + "/forecast?q=\(request!.city)&units=metric"
        case .WeatherServiceTypeByLocation:
            webServiceURL = webServiceURL! + "/forecast?lat=\(request!.latitude)&lon=\(request!.longitude)&units=metric"
        }
        
        super.setProperties()
    }
    
    override func parseJsonResponse(jsonString: String) {
        super.parseJsonResponse(jsonString)
        let weatherInfoDictionary = jsonResult as! NSDictionary?
        if let weatherDict = weatherInfoDictionary {
            
            weatherResponse.responseStatus = .ETBaseResponseStatusSuccess
            weatherResponse.forecastArray = self.parseWeatherInfoFromJSONDictionary(weatherDict, jsonString: jsonString)
        }
        else
        {
            //check for the offline cached data
            let cityName = request?.city
            
            let cacheJSONString = RCCoreDataManager.sharedInstance().getWeatherForecastJSON(cityName!)
            if cacheJSONString.characters.count > 0 {
                super.parseJsonResponse(cacheJSONString)
                let weatherInfoDictionary = jsonResult as! NSDictionary?
                
                if let weatherDict = weatherInfoDictionary {
                    
                    weatherResponse.responseStatus = .ETBaseResponseStatusSuccess
                    weatherResponse.forecastArray = self.parseWeatherInfoFromJSONDictionary(weatherDict, jsonString: jsonString)
                }
                
            }
        }
        
    }
    
    private func parseWeatherInfoFromJSONDictionary(jsonDataDictionary: NSDictionary, jsonString:String) -> [WSWeatherInfo] {
        
        var weatherInfoArray = [WSWeatherInfo]()
        let forecastListArray = jsonDataDictionary["list"] as! NSArray
        let cityDetailDictionary = jsonDataDictionary["city"] as! NSDictionary
        let cityName = cityDetailDictionary["name"] as! String
        
        //save the same to coredata
        if jsonString.characters.count > 0 {
            RCCoreDataManager.sharedInstance().saveorUpdateCityWeatherForecast(cityName.lowercaseString, forecastJSON: jsonString)
        }
        
        
        for weatherInfoDict in forecastListArray {
            let newWeatherInfo = WSWeatherInfo()
            let weatherDict = weatherInfoDict["main"] as! NSDictionary
            newWeatherInfo.temp = weatherDict["temp"] as! Float
            newWeatherInfo.forecastDate = NSDate.dateFromString(weatherInfoDict["dt_txt"] as! String, formatter: DT_FORMAT_yyyy_MM_dd_HH_mm_ss)!
            let date = NSDate.dateFromString(weatherInfoDict["dt_txt"] as! String, formatter: DT_FORMAT_yyyy_MM_dd_HH_mm_ss)
            
            //timestring and datestring properties are used for graph plotting in the weather details
            let dateString = NSDate.stringFromDate(date!, formatter: "dd")
            newWeatherInfo.dateString = dateString!
            newWeatherInfo.timeString = NSDate.stringFromDate(date!, formatter: "H")!
            weatherInfoArray.append(newWeatherInfo)
            
        }
        
        return weatherInfoArray
        
    }
    
}
