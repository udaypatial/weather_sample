//
//  ETBaseXMLWebService.swift
//  DataAPI
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import Foundation

class ETBaseXMLWebService : ETBaseWebService {
    
    override init() {
        super.init()
    }
    
    override func processWebResponse(strResponse: String) {
        processXMLResponse(strResponse)
    }
    
    func processXMLResponse(strResponse: String) {
        
        let responsedata: NSData? = strResponse.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        if responsedata != nil {
            //set these response data to NSXMLParser and then start parsing
            let parser: NSXMLParser = NSXMLParser(data: responsedata!)
            parser.shouldProcessNamespaces = shouldProcessNameSpaces()
            parser.shouldReportNamespacePrefixes = shouldReportNamespacePrefixes()
            parser.delegate = self
            parser.parse()
        } else {
            //fireResponseToTargets()
        }
    }
    
    internal func shouldProcessNameSpaces() -> Bool {
        return true
    }
    
    internal func shouldReportNamespacePrefixes() -> Bool {
        return true
    }
    
    //MARK: Xml parser delegate methods
    func parserDidStartDocument(parser: NSXMLParser!) {
        
    }
    
    // sent when the parser begins parsing of the document.
    func parserDidEndDocument(parser: NSXMLParser!) {
        
        //fireResponseToTargets()
    }
    
    // sent when the parser has completed parsing. If this is encountered, the parse was successful.
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        
        currentXmlElementName = elementName
        currentXmlElementContents = ""
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
    }
    
    // sent when an end tag is encountered. The various parameters are supplied as above.
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        
        currentXmlElementContents = currentXmlElementContents + string
    }
    
    // ...and this reports a fatal error to the delegate. The parser will stop parsing.
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        
        ETSharedLogger.logError("xml parse error : \(getClassName())")
    }
}