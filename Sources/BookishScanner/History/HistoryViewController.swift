// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class HistoryViewController: UITableViewController {
    enum HistorySection: CaseIterable {
        case history
    }
    
    class DataSource: UITableViewDiffableDataSource<HistorySection, HistoryItem> {
        let itemStore: HistoryManager
        var observer: Any?

        init(tableView: UITableView, itemStore: HistoryManager) {
            self.itemStore = itemStore
            super.init(
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

            observer = NotificationCenter.default.addObserver(forName: HistoryManager.historyUpdatedNotification, object: itemStore, queue: OperationQueue.main) {_ in
                self.updateUI(animated: true)
            }
        }
         
        deinit {
             if let observer = observer {
                 NotificationCenter.default.removeObserver(observer, name: HistoryManager.historyUpdatedNotification, object: itemStore)
             }
         }

        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            switch editingStyle {
                case .delete:
                    itemStore.remove(at: indexPath.row)
                default:
                    break
            }
        }

        func updateUI(animated: Bool) {
            var snapshot = NSDiffableDataSourceSnapshot<HistorySection, HistoryItem>()
            snapshot.appendSections([.history])
            snapshot.appendItems(itemStore.items)
            apply(snapshot, animatingDifferences: animated)
        }
    }
    
    lazy var dataSource = makeDataSource()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.updateUI(animated: false)
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView, itemStore: Application.shared.itemStore)
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
