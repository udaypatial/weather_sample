
//
//  ETBaseClientResponse.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public enum ETBaseResponseStatus : Int8 {
    
    case ETBaseResponseStatusNone = 0
    case ETBaseResponseStatusSuccess = 1
    case ETBaseResponseStatusFail = 2
}

public class ETBaseClientResponse {
    
    public var responseStatus: ETBaseResponseStatus = .ETBaseResponseStatusNone
    public var responseStatusMessage: String?
    public var responseDataArray: [AnyObject]?
    public var responseDataDictionary: NSDictionary?
    
    internal init() {
        
    }
    
    init(dataArray: [AnyObject]?) {
        
        self.responseDataArray = dataArray
    }
}