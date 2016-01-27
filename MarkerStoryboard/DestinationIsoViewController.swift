//
//  DestinationIsoViewController.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 11/28/15.
//  Copyright © 2015 Erik Allar. All rights reserved.
//

import UIKit
import GoogleMaps

class DestinationIsoViewController: UIViewController {
    var destination: EZYDestination?
    
    override func viewDidLoad() {
        print("This gets called when I perform segue")
        super.viewDidLoad()
//        let camera = GMSCameraPosition.cameraWithLatitude(41.8369, longitude: -87.6847, zoom: 6)
//        let currentMapView = GMSMapView.mapWithFrame(mapView.frame, camera: camera)
//        let marker = GMSMarker()
//        marker.position = camera.target
//        marker.snippet = "Hello World"
//        marker.appearAnimation = kGMSMarkerAnimationPop
//        marker.map = currentMapView
//        
//        self.mapView = currentMapView
        if let dest = destination {
            let latitude = dest.location.coordinate.latitude
            let longitude = dest.location.coordinate.longitude
            
            let camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom:13)
            let mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
            
            let marker = GMSMarker()
            marker.position = camera.target
            marker.snippet = "Hello World"
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView
            
            self.view = mapView
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
