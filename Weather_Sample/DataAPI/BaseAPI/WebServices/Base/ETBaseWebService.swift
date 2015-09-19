//
//  ETWebServiceBase.swift
//  DataLib
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

/**
Standard HTTP methods

- ETHTTPWebMethodGet: http GET method
- ETHTTPWebMethodPost: http POST method
- ETHTTPWebMethodPut: http PUT method
- ETHTTPWebMethodDelete: http DELETE method
*/
internal enum ETHTTPWebMethod : String {
    
    case ETHTTPWebMethodGet     = "GET"
    case ETHTTPWebMethodPost    = "POST"
    case ETHTTPWebMethodPut     = "PUT"
    case ETHTTPWebMethodDelete  = "DELETE"
    case ETHTTPWebMethodPatch   = "PATCH"
}

let KDefaultHTTPTimeOut: NSTimeInterval    = 60
let KContentType        = "Content-Type"
let KContentLength      = "Content-Length"
let KSoapAction         = "SOAPAction"

let KContentTypeJson    = "application/json"
let KContentTypeXML     = "text/xml; charset=utf-8"

/// base web service class to handle web service requsts.
class ETBaseWebService: NSObject, NSURLSessionDelegate, NSXMLParserDelegate {
    
    typealias ETWebServiceDataCompletionHandler = (response: ETBaseClientResponse?, error: NSError?) -> Void
    
    var urlRequest: NSMutableURLRequest?
    
    //can be override by the sub classes
    var strRequestData: String?
    var strSoapAction: String?
    var httpMethod: ETHTTPWebMethod = .ETHTTPWebMethodPost
    var httpBodyData: NSData?
    
    var templateFileName: String?
    var hardCodedFileName: String?
    
    var webServiceURL: String?
    var requestData: ETBaseClientRequest?
    var webServiceMethod: ETWebServiceMethod = .ETWebServiceMethodNone
    
    var wsUserName: String?
    var wsPassword: String?
    
    var currentAttribute: String?
    
    var isHardcodedMode = false
    var isParamentersEncrypted = false
    var shouldLogResponse = false
    
    weak var delegate: ETWebServiceDelegate?
    var completionHandler: ETWebServiceDataCompletionHandler?
    var strResponseData: String?
    var responseData: ETBaseClientResponse?
    var httpTimeOut: NSTimeInterval = 60
    var mutableResponseData: NSMutableData?
    var httpURLResponse: NSHTTPURLResponse?
    
    var startTime: Double = 0
    var xmlParsingTime: Double = 0
    var errorInfo: NSError?
    
    var currentXmlElementName: String = ""
    var currentXmlElementContents: String = ""
    
    var customHeaderFields: Dictionary<String, String> = Dictionary<String, String>()
    
    init(request: ETBaseClientRequest) {
        self.requestData = request
    }
    
    override init () {
        isHardcodedMode = (ETDataLibSettingsManager.sharedInstance().currentBuildMode == .ETBuildModeHardcoded)
    }
    
    private class func getWebServiceForWebMethod(method:ETWebServiceMethod, webServiceType: ETWebServiceType) -> ETBaseWebService? {
        
        let factory: ETBaseWebServiceFactory? = ETWebServiceTypeMapper.getWebServiceFactoryForWSType(webServiceType)
        let webService: ETBaseWebService? = factory!.webServiceFor(method)
        if webService != nil {
            webService!.webServiceMethod = method
            return webService
        } else {
            ETSharedLogger.logError("No webservice \(method.description()) defined in the factory class. Please define.")
            return nil
        }
    }
    
    ///used to send requests if we are using delegate approach
    private class func sendWebServiceRequestFor(method: ETWebServiceMethod, request: ETBaseClientRequest, delegate: ETWebServiceDelegate?) {
        
        let type: ETWebServiceType = ETWebServiceTypeMapper.webServiceTypeForWebServiceMethof(method)
        let targetWebService: ETBaseWebService? = ETBaseWebService.getWebServiceForWebMethod(method, webServiceType: type)
        targetWebService!.delegate = delegate
        targetWebService!.sendRequest(request)
    }
    
    ///used to send requests if we are using block based approach
    internal class func sendWebServiceRequestFor(request: ETBaseClientRequest, completionHandler: ETWebServiceDataCompletionHandler) {
        
        let type: ETWebServiceType = ETWebServiceTypeMapper.webServiceTypeForWebServiceMethof(request.method)
        let targetWebService: ETBaseWebService? = ETBaseWebService.getWebServiceForWebMethod(request.method, webServiceType: type)
        
        if let webService = targetWebService {
            webService.completionHandler = completionHandler
            webService.requestData = request
            webService.sendRequest(request)
        }
    }
    
    ///used in case we have some templates like xml or request for sending along with the web service
    private func loadWebServiceTemplateFromFile(template: String?) {
        
        if let fileName = template {
            
            if httpMethod == .ETHTTPWebMethodPost || httpMethod == .ETHTTPWebMethodPatch {
                
                let directoryPath: String? = ETDataLibSettingsManager.directoryPathFor(.ETDirectoryPathWebServiceTemplates)
                let filePath = ETDataLibSettingsManager.sharedInstance().rootDirectoryPath + "/" + directoryPath! + "/" + fileName + ".xcconfig"
                if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                    
                    strRequestData = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
                    strRequestData = strRequestData!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                } else {
                    //ETSharedLogger.logError("No template file defined : \(templateFileName).xcconfig")
                }
            }
        } else {
            //ETSharedLogger.logError("No template file defined : \(self).xcconfig")
        }
    }
    
    func sendRequest(request: ETBaseClientRequest) {
        
        loadWebServiceTemplateFromFile(templateFileName)
        
        if isHardcodedMode {
            loadHardcodedData()
            return
        }
        
        setProperties()
        
        let configObject: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session: NSURLSession = NSURLSession(configuration: configObject, delegate: self, delegateQueue: nil)
        
        ETSharedLogger.logInfo("\n=======================Request Start=======================\n")
        self.logWebServiceData()
        ETSharedLogger.logInfo("\n=======================Request End=======================\n")
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(urlRequest!, completionHandler: {(data, response, error) in
            
            self.httpURLResponse = response as? NSHTTPURLResponse
            
            if let dataRecieved = data {
                self.mutableResponseData = NSMutableData(data: dataRecieved)
                self.strResponseData = NSString(data: dataRecieved, encoding: NSUTF8StringEncoding) as? String
            }
            
            if (error != nil) {
                self.errorInfo = error
                ETSharedLogger.logError("NSURL session error : \(error!.localizedDescription)")
                print("error code \(error!.code)")
                
                //this is called when no internet connection.
                //TODO: define a enum for error codes
                if error!.code == -1009 {
                    self.strResponseData = ""
                    self.processWebResponse(self.strResponseData!)
                    self.processResponseDataBeforeParsingToDataManager(self.responseData)
                    self.fireResponseToTargets()
                }
                    
                else {
                    if self.completionHandler != nil {
                        self.completionHandler!(response: self.responseData, error: self.errorInfo)
                    }
                }
                
                
            }
            
            if self.strResponseData != nil {
                self.processWebResponse(self.strResponseData!)
                self.processResponseDataBeforeParsingToDataManager(self.responseData)
                self.fireResponseToTargets()
            } else {
                //ETSharedLogger.logError("strResponseData is null in sendRequest \(self.getClassName())")
            }
            ETSharedLogger.logInfo("\n=======================Response Start=======================\n")
            self.logWebServiceData()
            ETSharedLogger.logInfo("\n=======================Response End=======================\n")
        })
        task.resume()
    }
    
    //only for demo purpose, to display application capability to the business users
    func loadHardcodedData() {
        
        if hardCodedFileName == nil && templateFileName != nil {
            hardCodedFileName = templateFileName!
        }
        if hardCodedFileName == nil {
            ETSharedLogger.logError("no hardcoed file found")
        }
        
        let directoryPath: String? = ETDataLibSettingsManager.directoryPathFor(.ETDirectoryPathHardcodedData)
        let filePath = ETDataLibSettingsManager.sharedInstance().rootDirectoryPath + "/" + directoryPath! + "/" + hardCodedFileName!
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            
            strResponseData = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            processWebResponse(strResponseData!)
            processResponseDataBeforeParsingToDataManager(self.responseData)
            fireResponseToTargets()
        } else {
            ETSharedLogger.logError("Hardcoded file path not found : \(filePath)")
        }
    }
    
    //MARK: NSURLSessionDelegate methods
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        
        ETSharedLogger.logError("didBecomeInvalidWithError")
        self.logWebServiceData()
    }
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!){
        
        ETSharedLogger.logInfo("task-didReceiveChallenge : \(webServiceURL)")
        
        if challenge.previousFailureCount > 0 {
            ETSharedLogger.logError("Alert Please check the credential")
            completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
        } else {
            
            if wsUserName != nil && wsPassword != nil {
                let credential = NSURLCredential(user: wsUserName!, password: wsPassword!, persistence: .None)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            }
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        ETSharedLogger.logInfo("URLSessionDidFinishEventsForBackgroundURLSession")
    }
    
    //MARK: Overridable methods
    internal func setProperties() {
        
        httpTimeOut = (httpTimeOut < 0) ? KDefaultHTTPTimeOut : httpTimeOut
        webServiceURL = webServiceURL!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        urlRequest = NSMutableURLRequest(URL: NSURL(string: webServiceURL!)!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: httpTimeOut)
        
        if httpMethod == .ETHTTPWebMethodPost || httpMethod == .ETHTTPWebMethodPatch && strRequestData != nil {
            
            if httpBodyData != nil && httpBodyData!.length > 0 {
                
                urlRequest!.HTTPBody = httpBodyData!
                urlRequest!.addValue(String(httpBodyData!.length), forHTTPHeaderField: KContentLength)
            }
            urlRequest!.addValue(KContentTypeXML, forHTTPHeaderField: KContentType)
        }
        
        urlRequest!.HTTPMethod = httpMethod.rawValue
        
        for (headerFiledName, headerFiledValue) in customHeaderFields {
            urlRequest!.addValue(headerFiledValue, forHTTPHeaderField: headerFiledName)
        }
    }
    
    ///handles xml responses
    func processWebResponse(strResponse: String) {
        
        //processXMLResponse(strResponse)
    }
    
    func processResponseDataBeforeParsingToDataManager(response: ETBaseClientResponse?) {
        
    }
    
    ///enable logs in EtsharedLogger isLogEnabled() method
    internal func logWebServiceData() {
        
        ETSharedLogger.logInfo("\n======================= Start of \(getClassName()) data ==================== \n")
        
        if let url = webServiceURL {
            ETSharedLogger.logInfo("service \(httpMethod.rawValue) URL : \(url)\n")
        }
        
        if let hardCode = hardCodedFileName {
            ETSharedLogger.logInfo("hardCode file Name: \(hardCode)")
        }
        
        if let strSoapAction = strSoapAction {
            ETSharedLogger.logInfo("SOAP Action : \(strSoapAction)\n")
        }
        
        if let strRequest = strRequestData {
            ETSharedLogger.logInfo("request to server :\n\(strRequest)\n")
        }
        
        if let postData = httpBodyData {
            ETSharedLogger.logInfo("http \(httpMethod.rawValue) data length : \(Double(postData.length)) bytes\n")
        }else {
            ETSharedLogger.logError("http \(httpMethod.rawValue) data length : 0 bytes\n")
        }
        
        for (headerFiledName, headerFiledValue) in self.customHeaderFields {
            ETSharedLogger.logInfo("HTTP request Header field : \(headerFiledName) : \(headerFiledValue)")
        }
        
        if let strResponse = strResponseData {
            
            ETSharedLogger.logInfo("response from server :\n\(strResponse)\n")
        }
        ETSharedLogger.logInfo("\n======================= End of  \(getClassName()) data ================= \n\n\n")
    }
    
    internal func fireResponseToTargets () {
        
        if let handler = completionHandler {
            
            handler(response: responseData, error: self.errorInfo)
        }
    }
    
    internal func getClassName() -> String {
        
        let classString = NSStringFromClass(self.classForCoder)
        let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start:classString.startIndex, end: classString.endIndex), locale: nil)
        return classString.substringFromIndex(range!.endIndex)
    }
}
