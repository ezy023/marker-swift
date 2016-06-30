//
//  EZYImageIsolation.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 5/9/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

enum EZYImageUploadError: ErrorType {
    case InvalidAWSURL
    case InvalidHTTPRequest // This should be handled in teh HTTP client
    case InvalidAccessToken // This should be handled in teh HTTP client
}

protocol EZYImageIsolationProtocol {
    func confirmImageSelectionWithTags(image: UIImage, addedTags: [EZYDestinationTag])
}

class EZYImageIsolationViewController: UIViewController, TagSelectionDelegate {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var tagSelectionNavVC: UINavigationController?
    var selectedTagIds: [Int] = [Int]()
    var location: CLLocation = CLLocation()
    var uploadCompletionBlk: ((newDest: EZYDestination) -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        print("IN VIEW DID LOAD")
        if let theImage = self.image {
            print("THAT IMAGE THOUGH")
            self.imageView.image = theImage
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateWithTags" {
            if self.tagSelectionNavVC != nil {
                self.presentViewController(self.tagSelectionNavVC!, animated: true, completion: nil)
            } else {
                self.tagSelectionNavVC = segue.destinationViewController as? UINavigationController
                let tagSelectionTableVC = self.tagSelectionNavVC!.topViewController as! EZYTagsTableViewController
                tagSelectionTableVC.delegate = self
                tagSelectionTableVC.model = EZYTagModel()
            }
        }
    }
    
    func didUpdateSelectedTags(selectedTags: [EZYDestinationTag]) {
        self.selectedTagIds = selectedTags.map({(tag: EZYDestinationTag) in tag.tagId})
    }
    
    @IBAction func saveImageWithSelectedTags() {
        print("Saving")
        print(self.selectedTagIds)
        // need to check here to make sure there is a presenting view controller
        do {
            try uploadSavedImage()
        } catch EZYImageUploadError.InvalidAccessToken {
            let errorAlert: UIAlertController = UIAlertController(title: "Image Upload Error", message: "Invalid Access Token", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(errorAlert, animated: true, completion: {
                self.presentingViewController!.dismissViewControllerAnimated(true, completion: {
                    print("Dismissed with error")
                })
            })
        } catch {
            print("Some other error happenned \(error)")
        }
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: {
            print("Dismissed and saved")
        })
    }
    
    func uploadSavedImage() throws -> Void {
        if let editedImage = self.image {
            let imagePNGData: NSData? = UIImagePNGRepresentation(editedImage)
            let imageJPEGData: NSData? = UIImageJPEGRepresentation(editedImage, 1.0)
            let uuid = NSUUID().UUIDString
            let fileManager = NSFileManager.defaultManager()
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let filePathToWrite = "\(paths)/\(uuid).png"
            fileManager.createFileAtPath(filePathToWrite, contents: imagePNGData, attributes: nil)
            
            var params: [String: AnyObject] = [
                "latitude": self.location.coordinate.latitude,
                "longitude": self.location.coordinate.longitude,
                "tag_ids": self.selectedTagIds
            ]
            guard let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("access_token") else {
                throw EZYImageUploadError.InvalidAccessToken
            }
            let accessTokenHeaderString: String = "Token \(accessToken)"
            let headers = [
                "Authorization": accessTokenHeaderString
            ]
            
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
                                        Alamofire.request(.POST, "http://192.168.1.24:8000/users/1/locations/create/", parameters: params, encoding: .JSON, headers: headers).response { response in
                                            // At some point it would be nice to animate the new cell in?
                                            // This do block is for the fileManager
                                            do {
                                                try fileManager.removeItemAtPath(filePathToWrite)
                                                let imageAWSURL = NSURL(string: imageLocationOnAWS)
                                                let newDestination: EZYDestination = EZYDestination(imageURL: imageAWSURL!, destinationLocation: self.location)
                                                self.uploadCompletionBlk!(newDest: newDestination)
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
        }
    }
    
}