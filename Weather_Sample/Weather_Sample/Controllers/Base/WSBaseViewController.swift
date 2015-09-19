//
//  WSBaseViewController.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

//contains the common logic and reusable methods across the application
class WSBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        localize()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    //common methods to apply theme for buttons and other UI elements
    func applyTheme() {
        
    }
    
    //setting label values in case of localization
    func localize() {
        
    }
    
    func showLoading(message: String?) {
        
        var msg = message
        if msg == nil {
            msg = NSLocalizedString("Loading..", comment: "")
        }
        
        //progress bar customization according to weather app theme
        SVProgressHUD.setForegroundColor(ThemeManager.getColor("NAVIGATIONBAR_BAR_TINT_COLOR"))
        SVProgressHUD.setFont(UIFont(name: "HelveticaNeue", size: 13))
        //SVProgressHUD.setBackgroundColor(UIColor.blackColor())
        
        SVProgressHUD.showWithStatus(msg, maskType: 4)
    }
    
    func showLoading() {
        showLoading(nil)
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
    func handleErrorsFromServer(error: NSError) {
        
        hideLoading()
        
        let failureUrl = error.userInfo[NSURLErrorFailingURLStringErrorKey] as! NSString?
        ETSharedLogger.logError("Failuer URL : \(failureUrl)")
        switch error.code {
            
        default:
            break
        }
    }
    
    func getClassName() -> String {
        
        let classString = NSStringFromClass(self.classForCoder)
        let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start:classString.startIndex, end: classString.endIndex), locale: nil)
        return classString.substringFromIndex(range!.endIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
