//
//  DestinationModel.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 12/6/15.
//  Copyright © 2015 Erik Allar. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct EZYDestination: CustomDebugStringConvertible {
    // location, image, heading, other metadata around the image
    let imageFileURL: NSURL
    let location: CLLocation
//    let image: UIImage
    var debugDescription: String {
        return myDebugDescription()
    }
    
    init(imageURL: NSURL, destinationLocation: CLLocation) {
        imageFileURL = imageURL
        location = destinationLocation
    }
    
    init(dict: [String: AnyObject]) {
        let latString = dict["lat"] as! String
        let longString = dict["lng"] as! String
        let imageURLString = dict["image_url"] as! String
        let imageURL = NSURL(string: imageURLString)
        let lat = Double(latString)
        let long = Double(longString)
        let newDestLoc = CLLocation(latitude:lat!, longitude:long!)
        
        imageFileURL = imageURL!
        location = newDestLoc
    }
    
//    init(theImage: UIImage, destinationLocation: CLLocation) {
//        image = theImage
//        location = destinationLocation
//    }
    
    func myDebugDescription() -> String {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        return "Destination LAT: \(latitude) LONG:\(longitude)"
    }
}

//extension EZYDestination: Equatable {}
//
//func ==(lhs: EZYDestination, rhs: EZYDestination) -> Bool {
//    let areEqual = lhs.imageFileURL == rhs.imageFileURL &&
//                lhs.location == rhs.location
//    
//    return areEqual
//}

class DestinationModel {
    private var destinationArray: Array<EZYDestination>
    
    // init new
    // init and fetch destinations from api
    // add new destination
        // store image locally and async the image upload, then remove locally when upload is completed.
    // delete destination
    init() {
        destinationArray = []
        // will need to call api to fetch locations here.
    }
    
    func numberOfDestinations() -> Int {
        return destinationArray.count
    }
    
    func addDestination(destination: EZYDestination) {
        destinationArray.append(destination)
    }
    
    func allDestinations() -> [EZYDestination] {
        return destinationArray
    }
    
//    func deleteDestination(destination: EZYDestination) -> Void {
//        if let destIndex = destinationArray.indexOf({$0 == destination}) {
//            destinationArray.removeAtIndex(destIndex)
//        }
//    }
    
    func firstLoadOfObjects(completionHandler:() -> Void) -> Void {
        let nwk: EZYHTTPClient = EZYHTTPClient()
        nwk.GET("users/1/locations/?access_token=7b15237d-7b45-11e5-90e7-a45e60cc4223", params: nil, completionHandler: { (response) in
                print("IN HERE")
                print(response)
                if let locations = response["data"] as? [[String:AnyObject]] {
                    locations.forEach({ locationDict in
                        self.addDestination(EZYDestination(dict: locationDict))
                    })
                }
                completionHandler()
            }, errorHandler: nil)
    }
    
//    func firstLoadOfObjects(completionHandler: () -> ()) -> Void {
////        Alamofire.request(.GET, "http://192.168.1.24:8000/users/1/locations/?access_token=7b15237d-7b45-11e5-90e7-a45e60cc4223").responseJSON { response in
//        let url = NSURL(string: "http://192.168.1.24:8000/users/1/locations/?access_token=7b15237d-7b45-11e5-90e7-a45e60cc4223")
//        let request = NSURLRequest(URL: url!)
//        let mySession = NSURLSession.sharedSession()
//        let task = mySession.dataTaskWithRequest(request) {
//            (data, response, error) -> Void in
//            if (error != nil) {
//                return;
//            }
//            let httpResponse = response as! NSHTTPURLResponse
//            print("Status Code: \(httpResponse.statusCode)")
//            print("Data: \(data)")
////            var jsonString: String? = String(data: data!, encoding: NSUTF8StringEncoding)
//            do {
//                guard let urlDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] else {
//                    print("JSON Deserialization failed")
//                    return
//                }
//                if let locations = urlDict["data"] as? [[String:AnyObject]] {
//                    for location in locations {
//                        let latString = location["lat"] as! String
//                        let longString = location["lng"] as! String
//                        let imageURLString = location["image_url"] as! String
//                        let imageURL = NSURL(string: imageURLString)
//                        let lat = Double(latString)
//                        let long = Double(longString)
//                        let newDestLoc = CLLocation(latitude:lat!, longitude:long!)
//                        let newDest = EZYDestination(imageURL: imageURL!, destinationLocation: newDestLoc)
//                        self.addDestination(newDest)
//                    }
//                }
//                print("Debug line")
//                completionHandler()
//            } catch _ {
//                print("WRONG")
//            }
//            
////            print(jsonString!)
//            
//        }
//        task.resume()
//        
//
//    }
    
    func destinationAtIndex(indexPath: NSIndexPath) -> EZYDestination {
        let destination : EZYDestination = destinationArray[indexPath.row]
        return destination
    }
    
    func removeAll() {
        destinationArray.removeAll()
    }
}