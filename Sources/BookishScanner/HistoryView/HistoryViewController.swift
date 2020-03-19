// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Logger

let historyViewChannel = Channel("HistoryView")

class HistoryViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyViewChannel.log("loaded")
        dataSource.updateUI(animated: false)
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func makeDataSource() -> HistoryItemDataSource {
        return HistoryItemDataSource(tableView: tableView, itemStore: Application.shared.itemStore)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
}
