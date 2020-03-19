// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

class CandidateViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    var candidate: LookupCandidate!
    
    override func viewDidLoad() {
        let application = Application.shared
        titleLabel.text = candidate.title
        thumbnailWidthConstraint.constant = 32 // scene.viewState.thumbnailSize
        thumbnailHeightConstraint.constant = 32 // scene.viewState.thumbnailSize
        
        sourceLabel.text = "candidate.found.source".localized(with: ["source": candidate.service.name])
        authorsLabel.text = candidate.authors.joined(separator: ", ")
        if let urlString = candidate.image, let url = URL(string: urlString) {
            application.imageCache.image(for: url) { (image) in
                self.coverView.image = image
            }
        }
    }
    
    override var next: UIResponder? {
        return view.superview
    }
}
