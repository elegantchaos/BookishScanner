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
    let itemStore = HistoryManager()
    var itemObserver: Any?
    
    override func setUp(withOptions options: LaunchOptions) {
        super.setUp(withOptions: options)

        lookupManager.register(service: GoogleLookupService(name: "Google"))

        itemStore.load(fromStoreKey: stateKey, manager: lookupManager)
        itemObserver = NotificationCenter.default.addObserver(forName: HistoryManager.historyUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
            self.saveItems()
        }

        
        actionManager.installResponder()
        install(responder: actionManager.responder)
        actionManager.register([
            CaptureAction(),
        ])
    }
    
    override func tearDown() {
        saveItems()
    }
    
    class var shared: Application {
        UIApplication.shared.delegate as! Application
    }
    
    func saveItems() {
        itemStore.save(toStoreKey: stateKey)
    }
}
