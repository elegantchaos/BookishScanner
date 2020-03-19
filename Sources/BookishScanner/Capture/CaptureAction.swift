// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Actions

extension ActionKey {
    public static let candidate: ActionKey = "candidate"
    public static let query: ActionKey = "query"
}

public class CaptureAction: Action {
    public override func perform(context: ActionContext, completed: @escaping Completion) {
        if let candidate = context[.candidate] as? GoogleLookupCandidate, let query = context[.query] as? String {
            Application.shared.itemStore.add(query: query, candidate: candidate)
        }
        completed(.ok)
    }

}

public class ViewCandidateAction: Action {
    
}
