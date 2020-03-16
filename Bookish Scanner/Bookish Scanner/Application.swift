//
//  AppDelegate.swift
//  Bookish Scanner
//
//  Created by Developer on 16/03/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import UIKit
import ActionsKit
import ApplicationExtensions

@UIApplicationMain
class Application: BasicApplication {
    let lookupManager = LookupManager()
    let actionManager = ActionManagerMobile()
    let imageCache = ImageCache<UIImageFactory>()
    
    class var shared: Application {
        UIApplication.shared.delegate as! Application
    }
}

