// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

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

protocol ConfirmedItemCellRepresentable {
    var itemName: String { get }
    var itemSummary: String { get }
}

extension GoogleLookupCandidate: ConfirmedItemCellRepresentable {
    var itemName: String {
        return title
    }

    var itemSummary: String {
        var items: [String] = []
        items.append(contentsOf: authors)
        items.append(publisher)
        if let pages = info["pageCount"] as? NSNumber {
            items.append("\(pages) pages")
        }
        if let isbn = self.isbn {
            items.append("ISBN: \(isbn)")
        }

        return items.joined(separator: ", ")
    }

}
