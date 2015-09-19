//
//  ETBaseClientRequest.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

public class ETBaseClientRequest {
    
    private(set) var delegate: ETWebServiceDelegate?
    private(set) var method: ETWebServiceMethod = .ETWebServiceMethodNone
    
    convenience init(delegate: ETWebServiceDelegate) {
        
        self.init(method: .ETWebServiceMethodNone, delegate: delegate)
    }
    
    public convenience init(method: ETWebServiceMethod) {
        
        self.init(method: method, delegate: nil)
    }
    
    init(method: ETWebServiceMethod, delegate: ETWebServiceDelegate?) {
        
        self.method = method
        self.delegate = delegate
    }
}