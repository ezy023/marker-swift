//
//  EZYTagsTableViewController.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 3/27/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation
import UIKit

protocol FilterByTagSelectionDelegate {
    var selectedTagIds: [Int] { get set }
    
    func didUpdateSelectedTags(selectedTags: [EZYDestinationTag])
}

struct EZYDestinationTag {
    let tagId: Int
    let tagName: String
    var selected: Bool
}

class EZYTagModel {
    var tags: [EZYDestinationTag]
    var httpClient: EZYHTTPClientProtocol
    
    init(httpClient: EZYHTTPClientProtocol = EZYHTTPClient()) {
        self.httpClient = httpClient
        self.tags = [EZYDestinationTag]()
    }
    
    func tagAtIndexPath(indexPath: NSIndexPath) -> EZYDestinationTag {
        return self.tags[indexPath.row]
    }
    
    func numberOfTags() ->  Int {
        return self.tags.count
    }
    
    func selectedTags() -> [EZYDestinationTag] {
        let tags: [EZYDestinationTag] = self.tags.filter( {(tag: EZYDestinationTag) -> Bool in
            return tag.selected
        })
        
        return tags
    }
    
    func selectTagAtIndexPath(indexPath: NSIndexPath) -> Void {
        self.tags[indexPath.row].selected = true
    }
    
    func deselectTagAtIndexPath(indexPath: NSIndexPath) -> Void {
        self.tags[indexPath.row].selected = false
    }
    
    func deserializeTagFromDict(tagDict: [String:AnyObject]) -> EZYDestinationTag {
        let tagId = tagDict["id"] as! Int
        let tagName = tagDict["tag_name"] as! String
        let tag = EZYDestinationTag(tagId: tagId, tagName: tagName, selected: false)
        return tag
    }
    
    func fetchTagsForUser(userId: Int, completionBlk: () -> Void) {
        print("Fetching Tags for user \(userId)")
        self.httpClient.GET("users/\(userId)/tags/", params: nil, completionHandler: {(responseData) in
                if let tagsResponse: [[String: AnyObject]] = responseData["tags"] as? [[String: AnyObject]] {
                    for tagDictionary in tagsResponse {
                        if let tagDict: [String: AnyObject] = tagDictionary as [String: AnyObject] {
                            let tag: EZYDestinationTag = self.deserializeTagFromDict(tagDict)
                            self.tags.append(tag)
                        }
                    }
                    completionBlk()
                }
            }, errorHandler: {(error) in
                print(error?.description)
        })
    }
    
    func createNewTag(tagName: String, userId: Int, completionBlk: (responseData: [String: AnyObject]) -> Void) -> Void {
        print("Creating new tag \(tagName) for user \(userId)")
        let params: [String: AnyObject] = ["tag_name": tagName]
        self.httpClient.POST("users/\(userId)/tags/create/", params: params,
            completionHandler: {(responseData) in
                let tag: EZYDestinationTag = self.deserializeTagFromDict(responseData)
                self.tags.append(tag)
                completionBlk(responseData: responseData)
            }, errorHandler: {(error) in
                print("\(error?.localizedDescription)")
        })
    }
}

private let reuseIdentifier = "TagTableViewCell"

class EZYTagsTableViewController: UITableViewController {
    var delegate: FilterByTagSelectionDelegate?
    var model: EZYTagModel?
    
    init(delegate: FilterByTagSelectionDelegate, tagModel: EZYTagModel) {
        self.delegate = delegate
        self.model = tagModel
        super.init(style: UITableViewStyle.Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func dismissWithSelectedTags() {
        self.delegate!.didUpdateSelectedTags(self.model!.selectedTags())
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: {() in
            print("Dismissed!!")
        })
    }
    
    @IBAction func createNewTag() {
        let alertController = UIAlertController(title: "Add tag", message: "Create Tag", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textfield) in
            textfield.textAlignment = NSTextAlignment.Center
        }
        let confirmAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (action) in
            if let tagTextField = alertController.textFields?[0] {
                if let tagText = tagTextField.text {
                    guard let userId = NSUserDefaults.standardUserDefaults().valueForKey("user_id") else {
                        print("No User ID")
                        return
                    }
                    self.model!.createNewTag(tagText, userId: userId as! Int, completionBlk: {(response) in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    })
//                    if let userId: Int = NSUserDefaults.standardUserDefaults().valueForKey("userId") as! Int {
//                        print("\(userId)")
//                    }
                    
//                    self.model!.createNewTag(tagText, userId: userId, completionBlk: {(responseData) in
//                        print("Response: \(responseData.data)")
//                    })
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in
            print("Dismissing without tag")
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userId: Int = defaults.valueForKey("user_id") as! Int
        self.model?.fetchTagsForUser(userId) {() in
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tag = self.model?.tagAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = tag?.tagName
        if tag?.selected == true {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        cell.selectionStyle = .None
        
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model!.numberOfTags()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.model!.selectTagAtIndexPath(indexPath)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.model!.deselectTagAtIndexPath(indexPath)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }

}