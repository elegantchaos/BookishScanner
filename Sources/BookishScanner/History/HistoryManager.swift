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
    internal var items: [HistoryItem] = []
    internal let stateKey: String = "History"
    internal let itemPrefix = "Item:"
    
    public var count: Int { items.count }

    public init(store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default) {
        self.store = store
    }

    public func item(_ index: Int) -> HistoryItem {
        return items[index]
    }
    
    public func item(identifiedBy uuid: HistoryItem.Identifier)-> HistoryItem {
        return items.first(where: { $0.uuid == uuid })!
    }
    
    public func add(query: String, candidate: LookupCandidate) {
        let uuid = UUID().uuidString
        let item = HistoryItem(query: query, uuid: uuid, candidate: candidate)
        items.append(item)
        postUpdateNotification(reason: .addition)
    }
    
    public func remove(at index: Int) {
        items.remove(at: index)
        postUpdateNotification(reason: .deletion)
    }
    
    public func postUpdateNotification(reason: UpdateReason) {
        DispatchQueue.main.async {
            let notification = Notification(name: HistoryManager.historyUpdatedNotification, object: self, userInfo: ["reason": reason])
            NotificationQueue.default.enqueue(notification, postingStyle: .whenIdle, coalesceMask: .onName, forModes: nil)
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
                            let uuid = HistoryItem.Identifier(key.suffix(from: key.index(key.startIndex, offsetBy: itemPrefix.count)))
                            let item = HistoryItem(query: decoded.query, uuid: uuid, candidate: candidate, date: decoded.date)
                            items.append(item)
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
        for item in items {
            let record = CodableHistoryItem(from: item)
            if let data = try? encoder.encode(record) {
                let key = "Item:\(item.uuid)"
                store.set(data, forKey: key)
                keys.append(key)
            }
        }
        store.set(keys, forKey: key)
    }
}
