// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit
import Actions

class CaptureItemCell: UITableViewCell {
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    
    var candidate: LookupCandidate? = nil
    
    func setup(with candidate: LookupCandidate) {
        let storyboard = UIStoryboard(name: "Candidate", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! CandidateViewController
        vc.candidate = candidate
        self.candidate = candidate
        stack.insertArrangedSubview(vc.view, at: 0)
        addButton.actionID = "Capture"
        validateButtons(with: Application.shared.actionManager)
    }
}

extension CaptureItemCell: ActionContextProvider {
    func provide(context: ActionContext) {
        context[.candidate] = candidate
    }
}
