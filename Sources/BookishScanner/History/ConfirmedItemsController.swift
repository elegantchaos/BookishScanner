// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class ConfirmedItemsController: UITableViewController {
    var itemStore: ConfirmedItemsManager?
    var observer: Any?
    
    @IBAction func handleEdit(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemStore = Application.shared.itemStore
        observer = NotificationCenter.default.addObserver(forName: ConfirmedItemsManager.itemsUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
            self.tableView.reloadData()
        }
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer, name: ConfirmedItemsManager.itemsUpdatedNotification, object: itemStore)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item") as! ConfirmedItemCell
        if let item = itemStore?.item(indexPath.row) {
            cell.label.text = item.name
        }
        return cell
    }
}

