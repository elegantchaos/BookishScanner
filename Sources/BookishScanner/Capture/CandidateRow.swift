// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions

class CandidateRow: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    var candidate: LookupCandidate? = nil
    
    func setup(with candidate: LookupCandidate) {
        let application = Application.shared
        self.candidate = candidate
        titleLabel.text = candidate.title
        thumbnailWidthConstraint.constant = 32 // scene.viewState.thumbnailSize
        thumbnailHeightConstraint.constant = 32 // scene.viewState.thumbnailSize
        
        sourceLabel.text = "candidate.found.source".localized(with: ["source": candidate.service.name])
        authorsLabel.text = candidate.authors.joined(separator: ", ")
        addButton.actionID = "Capture"
        if let urlString = candidate.image, let url = URL(string: urlString) {
            application.imageCache.image(for: url) { (image) in
                self.coverView.image = image
            }
        }
        validateButtons(with: application.actionManager)
    }
}

extension CandidateRow: ActionContextProvider {
    func provide(context: ActionContext) {
        context[.candidate] = candidate
    }
}
