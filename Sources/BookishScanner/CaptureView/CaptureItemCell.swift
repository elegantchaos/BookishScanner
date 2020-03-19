// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions

class CaptureItemCell: UITableViewCell {
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    
    var candidateViewController: CandidateViewController!
    
    func setup(with candidate: LookupCandidate) {
        candidateViewController = CandidateViewController.viewController(for: candidate)
        stack.insertArrangedSubview(candidateViewController.view, at: 0)
        addButton.actionID = "Capture"
        validateButtons(with: Application.shared.actionManager)
    }
}

extension CaptureItemCell: ActionContextProvider {
    func provide(context: ActionContext) {
        context[.candidate] = candidateViewController.candidate
    }
}
