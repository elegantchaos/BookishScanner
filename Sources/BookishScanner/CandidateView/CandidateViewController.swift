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
    
    var candidate: LookupCandidate!
    
    class func viewController(for candidate: LookupCandidate) -> CandidateViewController {
        let storyboard = UIStoryboard(name: "Candidate", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! CandidateViewController
        vc.candidate = candidate
        return vc
    }
    
    override func viewDidLoad() {
        let application = Application.shared
        titleLabel.text = candidate.title
        
        sourceLabel.text = "candidate.found.source".localized(with: ["source": candidate.service.name])
        authorsLabel.text = candidate.summary
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
