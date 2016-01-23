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

class DestinationCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    var model: DestinationModel
    var selectedDestination: EZYDestination?
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        cell.image = rowDestination.image
        cell.imageView.image = rowDestination.image
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCamera" {
            let imagePickerController = segue.destinationViewController as! UIImagePickerController
            imagePickerController.sourceType = .Camera
            imagePickerController.delegate = self
        }
        
        if segue.identifier == "DestinationIsolationView" {
            let destinationIsoVC = segue.destinationViewController as! DestinationIsoViewController
            destinationIsoVC.destination = selectedDestination
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Finished Picking Image")
        guard let currentLocation = locationManager.location
        else {
            print("There was an error retrieving the location for this image")
            return
        }
        print("Latitude: \(currentLocation.coordinate.latitude). Longitude: \(currentLocation.coordinate.longitude)")
        let imagePNGData: NSData? = UIImagePNGRepresentation(image)
        let uuid = NSUUID().UUIDString
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var filePathToWrite = "\(paths)/\(uuid).png"
        fileManager.createFileAtPath(filePathToWrite, contents: imagePNGData, attributes: nil)
//        var getImagePath = paths.stringByAppendingString("\(uuid).png")
        
        if fileManager.fileExistsAtPath(filePathToWrite) {
            print("YES THE FILE IS HERE>>>>>>>>>>>>")
        }
//        let tmpFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
//        let imageFileURL = tmpFileURL.URLByAppendingPathComponent(uuid).URLByAppendingPathExtension("png")
//        let imagePathString: String = "\(imageFileURL)"
//        if let data = imagePNGData {
//            data.writeToFile(imagePathString, atomically: true)
//        }

        let params = ["test1": "erik", "test2": "starwars"];
        let paramsJSON: NSData

        do {
            paramsJSON = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
        } catch let error as NSError {
            paramsJSON = NSData()
            print(error)
        }
        
        Alamofire.request(.GET, "http://192.168.1.24:8000/users/1/dummy/").responseJSON { (response) in
            print(response)
            
            if let jsonData = response.result.value {
                let fields = jsonData["fields"]
                let awsURL = jsonData["url"] as! String
                let theFields = fields as! Dictionary<String, String>
                let fileURL = NSURL(string: filePathToWrite)
                
                Alamofire.upload(
                    .POST,
                    awsURL,
                    multipartFormData: { multipart in
//                        multipart.appendBodyPart(fileURL: imageFileURL, name: "file")
//                        multipart.appendBodyPart(fileURL: fileURL!, name: "file", fileName: theFields["key"]!, mimeType: "image/png")
//                        multipart.appendBodyPart(data: imagePNGData!, name: "file", fileName: "test-ios.png", mimeType: "image/png")
                        multipart.appendBodyPart(data: (theFields["x-amz-algorithm"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-algorithm")
                        multipart.appendBodyPart(data: (theFields["key"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "key")
                        multipart.appendBodyPart(data: (theFields["x-amz-signature"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-signature")
                        multipart.appendBodyPart(data: (theFields["x-amz-date"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-date")
                        multipart.appendBodyPart(data: (theFields["policy"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "policy")
                        multipart.appendBodyPart(data: (theFields["x-amz-credential"]!.dataUsingEncoding(NSUTF8StringEncoding))!, name: "x-amz-credential")
                        multipart.appendBodyPart(data: imagePNGData!, name: "file")
                        for (formKey, formValue) in theFields {
                            let k = formKey
                            let v = formValue
                            print("Key \(k): Value \(v)")
//                            let vData = v.dataUsingEncoding(NSUTF8StringEncoding)
//                            multipart.appendBodyPart(data: vData!, name: k)
                        }
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.response { request, response, data, error in
                                print("=====================")
                                debugPrint(request)
                                print("=====================")
                                debugPrint(response)
                                print("=====================")
                                let thedata = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                debugPrint(thedata)
                                print("=====================")
                                debugPrint(error)
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                        }
                    }
                )
                
//                Alamofire.upload(.POST, awsURL["url"], multipartFormData: { multipart in
//                        multipart.appendBodyPart(data: imageJPEGData!, name: "file")
//                        for (formKey, formValue) in fields {
//                            var k = formKey as! String
//                            var v = formValue as! String
//                            multipart.appendBodyPart(data: v.dataUsingEncoding(NSUTF8StringEncoding), name: k)
//                        }
//                    },
//                    encodingCompletion: { encodingResult in
//                        switch encodingResult {
//                        case .Success(let _, _, _):
//                            print("SUCCESS")
//                        case .Failure(let encodingError):
//                            print(encodingError)
//                        }
//                })
            }
        }

//        Alamofire.upload(.POST, "http://192.168.1.24:8000/users/1/locations/create/", multipartFormData: { multipart in
//                multipart.appendBodyPart(data: imageJPEGData!, name: "image")
//                multipart.appendBodyPart(data: paramsJSON, name: "imagemeta")
//            },
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .Success(let _, _, _):
//                    print("SUCCESS")
//                case .Failure(let encodingError):
//                    print(encodingError)
//                }
//            })
        
        let newDestination: EZYDestination = EZYDestination(theImage: image, destinationLocation: currentLocation)
        model.addDestination(newDestination)
        self.collectionView?.reloadData() // Do I need to do this?
        // Get NSData representation of the image to upload to api
//        let testImage = UIImage(named: "marker")
//        let imageJPEGData = UIImageJPEGRepresentation(testImage!, 1.0)

        
//        let postDataDictionary = ["image": image, "latitude": currentLocation.coordinate.latitude, "longitude": currentLocation.coordinate.longitude]
        
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
