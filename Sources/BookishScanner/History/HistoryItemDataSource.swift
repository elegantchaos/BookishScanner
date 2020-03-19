// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

enum HistorySection: CaseIterable {
    case history
}

class HistoryItemDataSource: UITableViewDiffableDataSource<HistorySection, HistoryItem> {
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
            historyViewChannel.log("loaded")
            self.updateUI(animated: true)
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer, name: HistoryManager.historyUpdatedNotification, object: itemStore)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        historyViewChannel.log("move from \(sourceIndexPath.row) to \(destinationIndexPath.row)")
        self.itemStore.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        self.updateUI(animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                historyViewChannel.log("delete \(indexPath.row)")
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
