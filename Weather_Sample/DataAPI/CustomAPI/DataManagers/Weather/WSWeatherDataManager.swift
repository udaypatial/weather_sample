//
//  WSWeatherDataManager.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

public class WSWeatherDataManager: ETBaseDataManager {
    public override class func sharedInstance() -> WSWeatherDataManager {
        
        struct StaticData {
            
            static var instance: WSWeatherDataManager? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&StaticData.onceToken) {
            StaticData.instance = WSWeatherDataManager()
        }
        return StaticData.instance!
    }
}
