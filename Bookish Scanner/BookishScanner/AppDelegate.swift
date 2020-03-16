//
//  AppDelegate.swift
//  Bookish Scanner
//
//  Created by Developer on 16/03/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import UIKit
import ApplicationExtensions

extension Application {
    class var shared: Application {
        UIApplication.shared.delegate as! Application
    }
}

@UIApplicationMain
class Application: BasicApplication {
    let lookupManager = LookupManager()
}

