//
//  WSUIUtils.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation


public class WSUIUtils {
    ///shows alert - assign delegate and callbacks both
    class func showConfirmAlertController(forController controller:UIViewController, withMessage message: String, title: String, cancelCallback: (() -> Void), withOkCallback okCallBack: (() -> Void), okTitle: String?, cancelTitle: String?) {
        
        let cancelButtonTitle = (cancelTitle == nil ) ? NSLocalizedString("Cancel", comment: "") : cancelTitle!
        let okBtnTitle = (okTitle == nil ) ? NSLocalizedString("Ok", comment: "") : okTitle!
        if #available(iOS 8.0, *) {
            let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action -> Void in
                //Do some stuff
                cancelCallback()
            }
            
            //Create and an option action
            let nextAction: UIAlertAction = UIAlertAction(title: okBtnTitle, style: .Default) { action -> Void in
                //Do some other stuff
                okCallBack()
            }
            
            actionSheetController.addAction(cancelAction)
            actionSheetController.addAction(nextAction)
            controller.presentViewController(actionSheetController, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            
            let alert = UIAlertView()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(cancelButtonTitle)
            alert.addButtonWithTitle(okBtnTitle)
            
            alert.delegate = controller
            alert.show()
        }
    }
    
    class func showAlertView(message: String, title: String) -> UIAlertView {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
        return alert
    }
    
}