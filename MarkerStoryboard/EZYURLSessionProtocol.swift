//
//  EZYURLSession.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 3/3/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation

typealias DataTaskResult = (NSData?, NSURLResponse?, NSError?) -> Void

protocol EZYURLSessionProtocol {
    func dataTaskWithRequest(request: NSURLRequest, completionHandler: DataTaskResult) -> NSURLSessionDataTask
}