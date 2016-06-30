//
//  DestinationCollectionViewController.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 11/28/15.
//  Copyright © 2015 Erik Allar. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

private let reuseIdentifier = "DestinationCell"

class DestinationCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, TagSelectionDelegate {
    var locationManager: CLLocationManager
    var model: DestinationModel
    var selectedDestination: EZYDestination?
    var selectedTagIds: [Int] = [Int]()
    var tagSelectionNavVC: UINavigationController?
    
    init(destinationModel: DestinationModel, collectionViewLayout: UICollectionViewLayout) {
        locationManager = CLLocationManager()
        model = destinationModel
        
        super.init(collectionViewLayout: collectionViewLayout)

    }
    
    required init?(coder aDecoder: NSCoder) {
        print("This is what you use!")
        locationManager = CLLocationManager()
        model = DestinationModel()
        
        super.init(coder: aDecoder)
        
        locationManager.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        let client = EZYHTTPClient();
        model.firstLoadOfObjects {
            print("In the completion handler")
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(DestinationCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        model.removeAll()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCamera" {
            let imagePickerController = segue.destinationViewController as! UIImagePickerController
            imagePickerController.sourceType = .Camera
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
        }
        
        if segue.identifier == "DestinationIsolationView" {
            let destinationIsoVC = segue.destinationViewController as! DestinationIsoViewController
            destinationIsoVC.destination = selectedDestination
        }
        
        if segue.identifier == "PresentTagSelection" {
            print("Presenting the tags selection view controller")
            if self.tagSelectionNavVC != nil {
                self.presentViewController(self.tagSelectionNavVC!, animated: true, completion: {() in
                    print("We are presenting the tag selection")
                })
            } else {
                print("Initializing new tag selection view controller")
                self.tagSelectionNavVC = segue.destinationViewController as! UINavigationController
                let tagSelectionTableVC = self.tagSelectionNavVC!.topViewController as! EZYTagsTableViewController
                tagSelectionTableVC.delegate = self
                tagSelectionTableVC.model = EZYTagModel()
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return model.numberOfDestinations()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: DestinationCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DestinationCollectionViewCell
        
        let rowDestination = model.destinationAtIndex(indexPath)
        let imageData = NSData(contentsOfURL: rowDestination.imageFileURL)
        let destinationImage = UIImage(data: imageData!)
        cell.image = destinationImage
        cell.imageView.image = destinationImage
//        cell.image = UIImage(imagewit
//        cell.imageView.image = rowDestination.image
//        if let cellImage = UIImage(named: "marker") {
//            cell.image = cellImage
//            cell.imageView.image = cellImage
//        }
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedDestination = self.model.destinationAtIndex(indexPath)

        performSegueWithIdentifier("DestinationIsolationView", sender: self)
    }

    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Finished Picking Image")
        guard let currentLocation = locationManager.location
            else {
                print("There was an error retrieving the location for this image") // probably want to display an error to the user
                return
        }
        let image: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let imageIsoVC: EZYImageIsolationViewController = storyboard.instantiateViewControllerWithIdentifier("imageIsolationViewController") as! EZYImageIsolationViewController
        imageIsoVC.image = image
        imageIsoVC.location = currentLocation
        imageIsoVC.uploadCompletionBlk = { (newDestination: EZYDestination) in
            self.model.addDestination(newDestination)
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
        self.dismissViewControllerAnimated(true, completion: {
            print("Need to dismiss the camera derp!!")
        })
        self.navigationController?.presentViewController(imageIsoVC, animated: true, completion: nil)
        print("PUSHING VC")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Cancelled Picking Image")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Getting a location authorization challenge here")
        if status == CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
    }
    
    // MARK: FilterByTagSelectionDelegate
    func didUpdateSelectedTags(selectedTags: [EZYDestinationTag]) {
        print("UPDATED TAGS")
        print(selectedTags)
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
