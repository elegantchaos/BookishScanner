//
//  ViewController.swift
//  Bookish Scanner
//
//  Created by Developer on 16/03/2020.
//  Copyright © 2020 Elegant Chaos. All rights reserved.
//

import UIKit

class ConfirmedItemsController: UITableViewController {
    var itemStore: ConfirmedItemsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemStore = Application.shared.itemStore
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
            cell.label.text = item.isbn
        }
        return cell
    }
}

