//
//  main.swift
//  MarkerStoryboard
//
//  Created by Erik Allar on 7/4/16.
//  Copyright © 2016 Erik Allar. All rights reserved.
//

import Foundation
import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate) : nil
}

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, delegateClassName())