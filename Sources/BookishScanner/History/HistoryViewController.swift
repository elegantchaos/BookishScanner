// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class HistoryViewController: UITableViewController {
    var itemStore: HistoryManager?
    var observer: Any?
    lazy var dataSource = makeDataSource()
    
    deinit {
         if let observer = observer {
             NotificationCenter.default.removeObserver(observer, name: HistoryManager.historyUpdatedNotification, object: itemStore)
         }
     }

    override func viewDidLoad() {
        super.viewDidLoad()
        itemStore = Application.shared.itemStore
        observer = NotificationCenter.default.addObserver(forName: HistoryManager.historyUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
            self.updateUI(animated: true)
        }

        updateUI(animated: false)
        navigationItem.rightBarButtonItem = editButtonItem
    }

    enum HistorySection: CaseIterable {
        case history
    }
    
    func updateUI(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<HistorySection, HistoryItem>()
        snapshot.appendSections([.history])
        if let store = itemStore {
            snapshot.appendItems(store.items)
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<HistorySection, HistoryItem> {
         return UITableViewDiffableDataSource(
             tableView: tableView,
             cellProvider: {  tableView, indexPath, item in
                 let cell = tableView.dequeueReusableCell(withIdentifier: "item") as! HistoryItemCell
                if let candidate = item.candidate as? ConfirmedItemCellRepresentable {
                     cell.nameLabel.text = candidate.itemName
                     cell.summaryLabel.text = candidate.itemSummary
                 }
                 return cell
             }
         )
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                itemStore?.remove(at: indexPath.row)
            default:
                break
        }
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
