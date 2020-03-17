// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let itemsManagerChannel = Channel("ItemsManager")

class ConfirmedItemsManager {
    internal let store: NSUbiquitousKeyValueStore
    internal var order: [String] = []
    internal var items: [String:ConfirmedItem] = [:]
    internal let stateKey: String = "State"
    
    public var count: Int { items.count }

    public init(store: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default) {
        self.store = store
    }

    public func item(_ index: Int) -> ConfirmedItem {
        let uuid = order[index]
        return items[uuid]!
    }
    
    public func add(item: ConfirmedItem) {
        let uuid = UUID().uuidString
        items[uuid] = item
        order.append(uuid)
    }
    
    func load(fromStoreKey key: String) {
        let decoder = JSONDecoder()
        let keys = store.dictionaryRepresentation.keys.filter({ $0.starts(with: "ISBN:") })
            for key in keys {
                if let jsonData = store.data(forKey: key) {
                    do {
                        let decoded = try decoder.decode(ConfirmedItem.self, from: jsonData)
                        items[key] = decoded
                        order.append(key)
                    } catch {
                        let json = String(data: jsonData, encoding: .utf8) ?? "<json unreadable>"
                        itemsManagerChannel.log("Failed to restore item \(json).\n\nError:\(error)")
                    }
                }
            }
        }
    
    func save(toStoreKey key: String) {
        let encoder = JSONEncoder()
        for (key, item) in items {
            if let data = try? encoder.encode(item) {
                store.set(data, forKey: key)
            }
        }
    }
}
