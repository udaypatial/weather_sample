//
//  ViewController.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: WSBaseViewController {
    
    ///used to fetch the current location
    var manager: OneShotLocationManager?
    let kPushByLocIdentifier = "pushByLocationIdentifier"
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: Action events
    
    @IBAction func btnByLocationClicked(sender: AnyObject) {
        
        showLoading()
        //initiate the location manager
        manager = OneShotLocationManager()
        
        //will check the location permission authorization status and if you have never granted this app location permissions will ask the user for permissions. Once permissions are granted will fetch the current location and invoke the given code closure.
        manager?.fetchWithCompletion({ (location, error) -> () in
            self.hideLoading()
            if let _ = location {
                print(location)
                //store the location to a local variable to pass in prepareforsegue method
                self.location = location!
                self.performSegueWithIdentifier(self.kPushByLocIdentifier, sender: self)
                
            } else if let err = error {
                //handle errors
                //can be handled in OneShotLocationManager class itself
                let errorType = OneShotLocationManagerErrors(rawValue: err.code)
                switch errorType!
                {
                case .AuthorizationDenied:
                    self.showLocationAlert()
                default:
                    print("location error")
                }
                print(err.localizedDescription)
            }
            //the manager instance cant be used to fetch location second time
            self.manager = nil
        })
    }
    
    //MARK: Helper methods
    
    func showLocationAlert() {
        WSUIUtils.showConfirmAlertController(forController: self, withMessage: NSLocalizedString("Could not fetch location. Please make sure you have enabled location services.", comment: ""), title: NSLocalizedString("Alert!", comment: ""), cancelCallback: { () -> Void in
            
            }, withOkCallback: { () -> Void in
                self.redirectUserToSettings()
            }, okTitle: NSLocalizedString("Settings", comment: ""), cancelTitle: NSLocalizedString("Cancel", comment: ""))
    }
    
    ///For a user who has disabled the location services redirect the user to location settings
    func redirectUserToSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
                
            case kPushByLocIdentifier:
                let weatherDetailsController = segue.destinationViewController as! WSWeatherDetailsViewController
                weatherDetailsController.location = location
                weatherDetailsController.weatherServiceType = .WeatherServiceTypeByLocation
                
            default: break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

