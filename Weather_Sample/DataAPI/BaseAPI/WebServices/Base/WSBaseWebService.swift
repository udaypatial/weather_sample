//
//  WSBaseWebService.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit

class WSBaseWebService: ETBaseJSONWebService {
    override init() {
        super.init()
        webServiceURL = ETDataLibSettingsManager.settingsValueForKey("WEB_SERVICE_URL") as? String
        wsUserName = ""
        wsPassword = ""
    }
}
