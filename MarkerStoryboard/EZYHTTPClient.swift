//
//  EZYHTTPClient.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 2/24/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation

extension NSURLSession : EZYURLSessionProtocol {}

protocol EZYHTTPClientProtocol {
    func GET(relativeUrl: String,
        params: [String: AnyObject]?,
        completionHandler: ((responseData: [String: AnyObject]) -> Void),
        errorHandler: ((error: NSError?) -> Void)?)
    
    func POST(relativeUrl: String,
        params: [String: AnyObject]?,
        completionHandler: ((responseData: [String: AnyObject]) -> Void),
        errorHandler: ((error: NSError?) -> Void)?)
}

class EZYHTTPClient: EZYHTTPClientProtocol {
//    let baseURL = "http://192.168.1.24:8000/"
    let baseURL = "http://127.0.0.1:8000/"
    let session: EZYURLSessionProtocol
    
    init(session: EZYURLSessionProtocol = NSURLSession.sharedSession()) {
        self.session = session
    }
    
    func GET(relativeUrl: String,
        params: [String: AnyObject]?,
        completionHandler: ((responseData: [String: AnyObject]) -> Void),
    errorHandler: ((error: NSError?) -> Void)?) {

        let fullURLString = baseURL + relativeUrl
        print("Request: \(fullURLString)")
        guard let url = NSURL(string: fullURLString) else {
            print("Improperly formatted url %s", relativeUrl)
            return;
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        // There must be a better way to handle access_tokens with an http client
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("access_token") {
            let accessTokenHeaderString: String = "Token \(accessToken)"
            request.setValue(accessTokenHeaderString, forHTTPHeaderField: "Authorization")
        }
        
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                errorHandler!(error: error)
            }
            
            do {
                let responseDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                completionHandler(responseData: responseDict)
            } catch {
                let jsonError: NSError = NSError(domain: "Invalid JSON returned", code: 1, userInfo: nil) // the 'code' should probably be some enum
                errorHandler!(error: jsonError)
            }
        }

        task.resume()
    }
    
    func POST(relativeUrl: String,
        params: [String: AnyObject]?,
        completionHandler: ((responseData: [String: AnyObject]) -> Void),
        errorHandler: ((error: NSError?) -> Void)?) {
            
        let fullURLString = baseURL + relativeUrl
        print("Request: \(fullURLString)")        
        guard let url = NSURL(string: fullURLString) else {
            NSLog("Improperly formatted url %s", relativeUrl)
            let urlError: NSError? = NSError(domain: "Invalid URL", code: 1, userInfo: nil)
            errorHandler!(error: urlError)
            return;
        }
                
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        // There must be a better way to handle access_tokens with an http client
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("access_token") {
            let accessTokenHeaderString: String = "Token \(accessToken)"
            request.setValue(accessTokenHeaderString, forHTTPHeaderField: "Authorization")
        }
            
            
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions())
        } catch {
            let jsonError: NSError = NSError(domain: "Invalid JSON returnded", code: 1, userInfo: nil)
            errorHandler!(error: jsonError)
        }
        
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                errorHandler!(error: error)
            }
            
            do {
                let responseDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                completionHandler(responseData: responseDict)
            } catch {
                let jsonError: NSError = NSError(domain: "Invalid JSON returnded", code: 1, userInfo: nil)
                errorHandler!(error: jsonError)
            }
        }
        task.resume()
    }
}