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

struct EZYDestination {
    // location, image, heading, other metadata around the image
    let image: UIImage
    let location: CLLocation
    let heading: CLHeading
    
}

extension EZYDestination: Equatable {}

func ==(lhs: EZYDestination, rhs: EZYDestination) -> Bool {
    let areEqual = lhs.image == rhs.image &&
                lhs.location == rhs.location
    
    return areEqual
}

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
    
    func addDestination(destination: EZYDestination) {
        destinationArray.append(destination)
    }
    
    func deleteDestination(destination: EZYDestination) -> Void {
        if let destIndex = destinationArray.indexOf({$0 == destination}) {
            destinationArray.removeAtIndex(destIndex)
        }
    }
}