//
//  CityWeather.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/19/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation
import CoreData

class CityWeather: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var cityName: String?
    @NSManaged var currentJSON: String?
    @NSManaged var forecastJSON: String?
}
