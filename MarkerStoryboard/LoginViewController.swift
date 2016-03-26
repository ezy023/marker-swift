//
//  LoginViewController.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 2/21/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var networking: EZYHTTPClient = {
        return EZYHTTPClient()
    }()
    
    init(networking: EZYHTTPClient) {
        super.init(nibName: nil, bundle: nil)
        self.networking = networking
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        print("Loggin In User Email \(email), Password: \(password)")
        let params: [String: AnyObject] = [
            "email": email,
            "password": password
        ]
        self.networking.POST("users/login/", params: params, completionHandler: { (responseData) in
                let accessToken = responseData["access_token"] as! String
                NSUserDefaults.standardUserDefaults().setValue(accessToken, forKey: "access_token")
                self.switchToMainStoryboardOnSuccess()
            }, errorHandler: { (error) in
                NSLog(error!.localizedDescription)
            })
    }
    
    @IBAction func createUserButtonPressed(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        print("Creating User With Email \(email), Password: \(password)")
        let params: [String: AnyObject] = [
            "email": email,
            "password": password
        ]
        self.networking.POST("users/login/", params: params, completionHandler: { (responseData) in
                let accessToken = responseData["access_token"]
                NSUserDefaults.standardUserDefaults().setValue(accessToken, forKey: "access_token")
                self.switchToMainStoryboardOnSuccess()
            }, errorHandler: { (error) in
                NSLog(error!.localizedDescription)
            })
//        let url = NSURL(string: "http://192.168.1.24:8000/users/create/")
//        let request = NSMutableURLRequest(URL: url!)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.HTTPMethod = "POST"
//        do {
//            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options:NSJSONWritingOptions())
//        } catch {
//            print("Error encoding JSON")
//        }
//        let urlSession = NSURLSession.sharedSession()
//        let createUserTask = urlSession.dataTaskWithRequest(request) { (data, response, error) in
//            self.debugResponse(data, response: response, error: error)
//            do {
//                let respDict: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
//                let accessToken = respDict["access_token"] as! String
//                NSUserDefaults.standardUserDefaults().setValue(accessToken, forKey: "access_token")
//                self.switchToMainStoryboardOnSuccess()
//            } catch {
//                print("THERE WAS AN ERROR CREATING USER")
//            }
//        }
//        
//        createUserTask.resume()
    }
    
    func debugResponse(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void {
        do {
            if let respDict: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject] {
                print("Access Token \(respDict["access_token"] as! String)")
            }
        } catch {
            print("Error deserializing JSON")
        }
        debugPrint(NSString(data: data!, encoding: NSUTF8StringEncoding))
        debugPrint(response)
        debugPrint(error)
    }
    
    func switchToMainStoryboardOnSuccess() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let viewController = storyboard.instantiateInitialViewController()! as UIViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        NSOperationQueue.mainQueue().addOperationWithBlock({
            appDelegate.window?.rootViewController = viewController
        })
    }
}