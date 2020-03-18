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
    var itemObserver: Any?
    
    override func setUp(withOptions options: LaunchOptions) {
        super.setUp(withOptions: options)
        
        itemStore.load(fromStoreKey: stateKey)
        itemObserver = NotificationCenter.default.addObserver(forName: ConfirmedItemsManager.itemsUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
            self.saveItems()
        }

        lookupManager.register(service: GoogleLookupService(name: "Google"))
        
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

extension GoogleLookupCandidate: ConfirmedItemRepresentable {
    var name: String? {
        return info["title"] as? String
    }

    var serviceName: String {
        return service.name
    }
    
    var serviceData: String {
        return ""
    }
    
}

   
//    public override func makeBook(in collection: CollectionContainer, completion: @escaping (Book) -> Void) {
//        let info = self.info
//        super.makeBook(in: store) { book in
//            if let pages = info["pageCount"] as? NSNumber {
//                book.pages = pages.int16Value
//            }
//
//            if let isbn = GoogleLookupCandidate.isbn(from: info) {
//                book.isbn = isbn
//            }
//
//            if let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted) {
//                book.importRaw = String(data: data, encoding: .utf8)
//            }
//            completion(book)
//        }
//    }
