//
//  DestinationIsoViewController.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 11/28/15.
//  Copyright © 2015 Erik Allar. All rights reserved.
//

import UIKit

class DestinationIsoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    internal var image: UIImage?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image

        // Do any additional setup after loading the view.
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