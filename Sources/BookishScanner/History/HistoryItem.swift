// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/// History item in a form that can be coded.
struct CodableHistoryItem: Codable {
    let query: String
    let date: Date
    let candidate: LookupCandidate.Persisted
    
    init(from item: HistoryItem) {
        query = item.query
        date = item.date
        candidate = item.candidate.persisted
    }
}


/// History item.
/// Contains a record of the query used to find the item,
/// the date the query was submitted, and the lookup candidate that
/// was returned.
struct HistoryItem {
    let query: String
    let candidate: LookupCandidate
    let date: Date

    init(query: String, candidate: LookupCandidate, date: Date? = nil) {
        self.query = query
        self.candidate = candidate
        self.date = date ?? Date()
    }
}

