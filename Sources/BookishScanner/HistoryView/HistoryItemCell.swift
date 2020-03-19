// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class HistoryItemCell: UITableViewCell {
    @IBOutlet weak var stack: UIStackView!
    
    override func prepareForReuse() {
        if let view = stack.arrangedSubviews.first {
            stack.removeArrangedSubview(view)
        }
    }
}
