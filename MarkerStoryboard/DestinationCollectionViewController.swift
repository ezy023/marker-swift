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

class DestinationCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, FilterByTagSelectionDelegate {
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
//        model.firstLoadOfObjects {
//            print("In the completion handler")
//            dispatch_async(dispatch_get_main_queue(), {
//                self.collectionView?.reloadData()
//            })
//        }
        

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
//        let testImage = UIImage(named: "marker")
//        let imageJPEGData: NSData? = UIImageJPEGRepresentation(testImage!, 1.0)
//        let params = ["test1": "erik", "test2": "starwars"];
//        let paramsJSON: NSData
//        
//        do {
//            paramsJSON = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
//        } catch let error as NSError {
//            paramsJSON = NSData()
//            print(error)
//        }
//
//        Alamofire.upload(.POST, "http://127.0.0.1:8000/users/create/", multipartFormData: { multipart in
//                multipart.appendBodyPart(data: imageJPEGData!, name: "testimage")
//                multipart.appendBodyPart(data: paramsJSON, name: "imagemeta")
//            },
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let _, _, _):
//                    print("SUCCESS")
//                    collectionView.reloadData()
//                case .Failure(let encodingError):
//                    print(encodingError)
//                }
//            })
////        Alamofire.request(.GET, "http://127.0.0.1:8000").response {request, response, data, error in
////            print(response)
////            print(data)
////            print(error)
////        }
//        let macIP: String = "http://192.168.1.24:8000"
//        print("Making GET to \(macIP)")
//        Alamofire.request(.GET, macIP)
//=====================================================================
        selectedDestination = self.model.destinationAtIndex(indexPath)

        performSegueWithIdentifier("DestinationIsolationView", sender: self)
    }

    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Finished Picking Image")
        guard let currentLocation = locationManager.location
        else {
            print("There was an error retrieving the location for this image")
            return
        }
        guard let editInfo = editingInfo else {
            print("No Editing Info")
            return
        }
        
        guard let editedImage: UIImage = editInfo[UIImagePickerControllerEditedImage] as? UIImage else {
            print("No Edited Image")
            return
        }
        
        let imagePNGData: NSData? = UIImagePNGRepresentation(editedImage)
        let imageJPEGData: NSData? = UIImageJPEGRepresentation(editedImage, 1.0)
        let uuid = NSUUID().UUIDString
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePathToWrite = "\(paths)/\(uuid).png"
        fileManager.createFileAtPath(filePathToWrite, contents: imagePNGData, attributes: nil)
        
        var params: [String: AnyObject] = ["latitude": currentLocation.coordinate.latitude, "longitude": currentLocation.coordinate.longitude]
        
        Alamofire.request(.GET, "http://192.168.1.24:8000/users/1/locations/aws_post/").responseJSON { (response) in
            print(response)
            if let jsonData = response.result.value {
                let fields = jsonData["fields"]
                let awsURL = jsonData["url"] as! String
                let theFields = fields as! Dictionary<String, String>
                
                Alamofire.upload(
                    .POST,
                    awsURL,
                    multipartFormData: { multipart in
                        multipart.appendBodyPart(data: (theFields["x-amz-algorithm"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-algorithm")
                        multipart.appendBodyPart(data: (theFields["key"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "key")
                        multipart.appendBodyPart(data: (theFields["x-amz-signature"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-signature")
                        multipart.appendBodyPart(data: (theFields["x-amz-date"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-date")
                        multipart.appendBodyPart(data: (theFields["policy"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "policy")
                        multipart.appendBodyPart(data: (theFields["x-amz-credential"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-credential")
                        multipart.appendBodyPart(data: imageJPEGData!, name: "file", fileName: "test-ios.png", mimeType: "image/jpeg")
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.response { request, response, data, error in
                                if let imageLocationOnAWS = response?.allHeaderFields["Location"] as? String {
                                    params["image_url"] = imageLocationOnAWS
                                    Alamofire.request(.POST, "http://192.168.1.24:8000/users/1/locations/create/?access_token=7b15237d-7b45-11e5-90e7-a45e60cc4223", parameters: params, encoding: .JSON, headers: nil).response { response in
                                        self.collectionView?.reloadData()
                                        // At some point it would be nice to animate the new cell in?
                                        do {
                                            try fileManager.removeItemAtPath(filePathToWrite)
                                            let imageAWSURL = NSURL(string: imageLocationOnAWS)
                                            let newDestination: EZYDestination = EZYDestination(imageURL: imageAWSURL!, destinationLocation: currentLocation)
                                            self.model.addDestination(newDestination)
                                        } catch {
                                            print("Error removing file at path \(filePathToWrite)")
                                        }
                                    }
                                } else {
                                    print("No Location for image returned")
                                }
//                                let thedata = NSString(data: data!, encoding: NSUTF8StringEncoding) // Helpful to print AWS Response
                            }
                        case .Failure(let encodingError):
                            debugPrint(encodingError)
                        }
                    }
                )
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil) // In this completion block reload collectionView data to refresh with new image
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
