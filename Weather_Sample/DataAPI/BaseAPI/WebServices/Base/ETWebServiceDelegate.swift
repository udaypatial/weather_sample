//
//  WebServiceDelegate.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

protocol ETWebServiceDelegate : NSObjectProtocol {
    
    /**
    * once the responce is coming this delegate method is getting called in the main thread.
    * @author Uday Patial
    * @param webService Requested WebService
    * @param response response from the server. can be anything
    * @return nothing is returning
    */
    func responseRecievedFor(webService: ETBaseWebService, response:ETBaseClientResponse?)
    
    /// Add new message between source to destination timeline
    ///
    /// @param sourceId Source timeline entity ID
    /// @param destId Destination timeline entity ID
    /// @param name Message name
    /// @return A newly created message instance
    func invalidResponseRecievedFor(webService webService: ETBaseWebService, response:ETBaseClientResponse)
    
    func timeoutOccuredFor(webService webService: ETBaseWebService)
    
    func connectionFailedFor(webService webService: ETBaseWebService, error: NSError)
    
    func connectionDidFailedWithExceptionFor(webService webService: ETBaseWebService, exception: NSException)
    
    func invalidCredentialsRecievedFor(webService webService: ETBaseWebService)
}