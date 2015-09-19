//
//  WSCityDetailViewController.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSCityDetailViewController: WSBaseViewController {

    let kPushWeatherDetailsIdentifier = "pushWeatherDetailsFromCityIdentifier"
    
    @IBOutlet weak var txtCity: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
                
            case kPushWeatherDetailsIdentifier:
                let city = txtCity.text
                if city?.removeWhitespace().characters.count  > 0 {
                    let weatherDetailsController = segue.destinationViewController as! WSWeatherDetailsViewController
                    weatherDetailsController.city = (city?.removeWhitespace())!
                    weatherDetailsController.weatherServiceType = .WeatherServiceTypeByCity
                }
                else {
                    WSUIUtils.showAlertView(NSLocalizedString("City field cannot be left blank.", comment: ""), title: NSLocalizedString("Alert", comment: ""))
                }
                
                
            default: break
            }
        }
    }
    

}
