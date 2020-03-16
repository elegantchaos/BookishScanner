// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import ActionsKit
import ApplicationExtensions

@UIApplicationMain
class Application: BasicApplication {
    let stateKey: String = "State"
    let lookupManager = LookupManager()
    let actionManager = ActionManagerMobile()
    let imageCache = ImageCache<UIImageFactory>()
    let itemStore = ConfirmedItemsManager()
    
    override func setUp(withOptions options: LaunchOptions) {
        super.setUp(withOptions: options)
        
        itemStore.load(fromStoreKey: stateKey)
        if itemStore.count == 0 {
            itemStore.add(item: "Item 1")
            itemStore.add(item: "Item 2")
        }
        
        lookupManager.register(service: GoogleLookupService(name: "Google"))
        
        actionManager.register([
            AddCandidateAction(),
            ViewCandidateAction()
        ])
    }
    
    override func tearDown() {
        itemStore.save(toStoreKey: stateKey)
    }
    
    class var shared: Application {
        UIApplication.shared.delegate as! Application
    }
}

