//
//  WSFetchWeatherInfoService.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/19/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation
import CoreData

public class RCCoreDataManager : ETBaseDataManager {
    
    private let kDataBaseName: String    = "Weather_Sample.sqlite"
    
    //MARK: CoreData Entity names
    private let kEntityCityWeather                    = "CityWeather"
    
    //MARK: CoreData Entity attribute names
    private let kEntityAttributeCityName              = "cityName"
    private let kEntityAttributeCurrentJSON           = "currentJSON"
    private let kEntityAttributeForecastJSON          = "forecastJSON"
    
    
    public class func sharedInstance() -> RCCoreDataManager! {
        
        struct StaticData {
            
            static var instance: RCCoreDataManager? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&StaticData.onceToken) {
            
            StaticData.instance = RCCoreDataManager()
        }
        return StaticData.instance!
    }
    
    // MARK: - Core Data stack
    private lazy var applicationDocumentsDirectory: NSURL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.emaartechnologies.tester" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    // MARK: - Core Data stack
    private lazy var applicationCachesDirectory: NSURL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.emaartechnologies.tester" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[0]
        }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        let modelURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("Weather_Sample.momd")
        
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        var dataBaseName = "Weather_Sample.sqlite"
        //dataBaseName = ETEncryptionWrapper.AES128EncryptedMessage(dataBaseName, withKey: "12345678")
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationCachesDirectory.URLByAppendingPathComponent(dataBaseName)
        //ETSharedLogger.logInfo("SQLite Database Url : \(url)")
        var error: NSError? = nil
        
        // important part starts here to avoid crashing, when we change the data model
        var coreDataOptions = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: coreDataOptions)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            
            var failureReason = "There was an error creating or loading the application's saved data."
            
            var dict = [String : AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "com.uvsp.weather_Sample", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            ETSharedLogger.logError("Unresolved error \(error), \(error!.userInfo)")
            //abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    private lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    private func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            do {
                try moc.save()
            } catch let error1 as NSError {
                error = error1
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                ETSharedLogger.logError("Unresolved error \(error), \(error!.userInfo)")
                //abort()
            }
        }
    }
    
    //MARK: Funcstions save/delete/update core data for weather sample
    
    
   
    
    //MARK: Custom Helper methods
    private func fetchObjects(fetchRequest: NSFetchRequest) -> [NSManagedObject]? {
        
        var fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try self.managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            return (fetchedResults != nil) ? fetchedResults : []
        } catch {
            ETSharedLogger.logError("Could not fetch")
            return []
        }
    }
    
    private func deleteAllObjectsFromEntity(entityName: String, shouldSaveContext: Bool) -> Bool {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try self.managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for managedObject in fetchedResults! {
                self.managedObjectContext!.deleteObject(managedObject)
            }
            if shouldSaveContext {
                saveContext()
            }
            return true
        } catch {
            ETSharedLogger.logError("Could not fetch")
            return false
        }
    }
    
    private func deleteObjectsForFetchRequest(fetchRequest: NSFetchRequest, shouldSaveContext: Bool) -> Bool {
        
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try self.managedObjectContext!.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for managedObject in fetchedResults! {
                self.managedObjectContext!.deleteObject(managedObject)
            }
            
            if shouldSaveContext {
                saveContext()
            }
            return true
        } catch {
            ETSharedLogger.logError("Could not delete")
            return false
        }
    }
    
    //MARK: Project helper methods
    func saveorUpdateCityWeather( var cityName:String, currentJSON:String) {
        cityName = cityName.removeWhitespace()
        let fetchRequest = NSFetchRequest(entityName: kEntityCityWeather)
        let resultPredicate = NSPredicate(format: "%K == %@", kEntityAttributeCityName, cityName.lowercaseString)
        fetchRequest.predicate = resultPredicate
        
        let cityManagedObjects = fetchObjects(fetchRequest) as! [CityWeather]
        if cityManagedObjects.count > 0 {
            //update the object
            let cityWeatherManagedObject = cityManagedObjects[0]
            cityWeatherManagedObject.currentJSON = currentJSON
        }
        else {
            //create new object
            let entity =  NSEntityDescription.entityForName(kEntityCityWeather, inManagedObjectContext:self.managedObjectContext!)
            let transactionManagedObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext!) as! CityWeather
            transactionManagedObj.currentJSON = currentJSON
            transactionManagedObj.cityName = cityName
        }
        saveContext()
    }
    
    func getWeatherInfoJSON(var cityName:String) -> String {
        cityName = cityName.removeWhitespace()
        let fetchRequest = NSFetchRequest(entityName: kEntityCityWeather)
        let resultPredicate = NSPredicate(format: "%K == %@", kEntityAttributeCityName, cityName.lowercaseString)
        fetchRequest.predicate = resultPredicate
        let cityManagedObjects = fetchObjects(fetchRequest) as! [CityWeather]
        if cityManagedObjects.count > 0 {
            let cityWeatherManagedObject = cityManagedObjects[0]
            if let currentJSON = cityWeatherManagedObject.currentJSON {
                return currentJSON
            }
        }
        return ""
    }
    
    func getWeatherForecastJSON(var cityName:String) -> String {
        cityName = cityName.removeWhitespace()
        let fetchRequest = NSFetchRequest(entityName: kEntityCityWeather)
        let resultPredicate = NSPredicate(format: "%K == %@", kEntityAttributeCityName, cityName.lowercaseString)
        fetchRequest.predicate = resultPredicate
        let cityManagedObjects = fetchObjects(fetchRequest) as! [CityWeather]
        if cityManagedObjects.count > 0 {
            let cityWeatherManagedObject = cityManagedObjects[0]
            if let forecastJSON = cityWeatherManagedObject.forecastJSON {
                return forecastJSON
            }
        }
        return ""
    }
    
    func saveorUpdateCityWeatherForecast(var cityName:String, forecastJSON:String) {
        cityName = cityName.removeWhitespace()
        let fetchRequest = NSFetchRequest(entityName: kEntityCityWeather)
        let resultPredicate = NSPredicate(format: "%K == %@", kEntityAttributeCityName, cityName.lowercaseString)
        fetchRequest.predicate = resultPredicate
        
        let cityManagedObjects = fetchObjects(fetchRequest) as! [CityWeather]
        if cityManagedObjects.count > 0 {
            //update the object
            let cityWeatherManagedObject = cityManagedObjects[0]
            cityWeatherManagedObject.forecastJSON = forecastJSON
        }
        else {
            //create new object
            let entity =  NSEntityDescription.entityForName(kEntityCityWeather, inManagedObjectContext:self.managedObjectContext!)
            let transactionManagedObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:self.managedObjectContext!) as! CityWeather
            transactionManagedObj.forecastJSON = forecastJSON
            transactionManagedObj.cityName = cityName
        }
        saveContext()
    }
    
    
}