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
//    let imageFileURL: NSURL
    let location: CLLocation
    let image: UIImage
    var debugDescription: String {
        return myDebugDescription()
    }
    
//    init(imageURL: NSURL, destinationLocation: CLLocation) {
//        imageFileURL = imageURL
//        location = destinationLocation
//    }
    
    init(theImage: UIImage, destinationLocation: CLLocation) {
        image = theImage
        location = destinationLocation
    }
    
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
    
//    func deleteDestination(destination: EZYDestination) -> Void {
//        if let destIndex = destinationArray.indexOf({$0 == destination}) {
//            destinationArray.removeAtIndex(destIndex)
//        }
//    }
    
    func destinationAtIndex(indexPath: NSIndexPath) -> EZYDestination {
        let destination : EZYDestination = destinationArray[indexPath.row]
        return destination
    }
    
    func removeAll() {
        destinationArray.removeAll()
    }
}