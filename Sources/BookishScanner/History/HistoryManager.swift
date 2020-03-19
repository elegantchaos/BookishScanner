// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let historyManagerChannel = Channel("History")

class HistoryManager {
    static let historyUpdatedNotification = NSNotification.Name(rawValue: "com.elegantchaos.bookish.scanner.history.updated")
    
    enum UpdateReason {
        case addition
        case deletion
        case reload
    }
    
    internal let store: NSUbiquitousKeyValueStore
    internal var order: [String] = []
    internal var items: [String:HistoryItem] = [:]
    internal let stateKey: String = "History"
    internal let itemPrefix = "Item:"
    
    public var count: Int { items.count }

    public init(store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default) {
        self.store = store
    }

    public func item(_ index: Int) -> HistoryItem {
        let uuid = order[index]
        return items[uuid]!
    }
    
    public func add(item: HistoryItem) {
        let uuid = UUID().uuidString
        items[uuid] = item
        order.append(uuid)
        postUpdateNotification(reason: .addition)
    }
    
    public func remove(at index: Int) {
        let uuid = order[index]
        order.remove(at: index)
        items[uuid] = nil
        postUpdateNotification(reason: .deletion)
    }
    
    public func postUpdateNotification(reason: UpdateReason) {
        DispatchQueue.main.async {
            let notification = Notification(name: HistoryManager.historyUpdatedNotification, object: self, userInfo: ["reason": reason])
            NotificationCenter.default.post(notification)
        }
    }
    
    func load(fromStoreKey key: String, manager: LookupManager) {
        let decoder = JSONDecoder()
        let keys = store.array(forKey: key) as? [String] ?? store.dictionaryRepresentation.keys.filter({ $0.starts(with: itemPrefix) })
            for key in keys {
                if let jsonData = store.data(forKey: key) {
                    do {
                        let decoded = try decoder.decode(CodableHistoryItem.self, from: jsonData)
                        if let candidate = manager.restore(persisted: decoded.candidate) {
                            let uuid = String(key.suffix(from: key.index(key.startIndex, offsetBy: itemPrefix.count)))
                            items[uuid] = HistoryItem(query: decoded.query, candidate: candidate, date: decoded.date)
                            order.append(uuid)
                        }
                    } catch {
                        let json = String(data: jsonData, encoding: .utf8) ?? "<json unreadable>"
                        historyManagerChannel.log("Failed to restore item \(json).\n\nError:\(error)")
                    }
                }
            }
        }
    
    func save(toStoreKey key: String) {
        let encoder = JSONEncoder()
        var keys: [String] = []
        for (uuid, item) in items {
            let record = CodableHistoryItem(from: item)
            if let data = try? encoder.encode(record) {
                let key = "Item:\(uuid)"
                store.set(data, forKey: key)
                keys.append(key)
            }
        }
        store.set(keys, forKey: key)
    }
}
