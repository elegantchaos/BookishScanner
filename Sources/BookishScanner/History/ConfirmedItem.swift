// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ConfirmedCodable: Codable {
    let query: String
    let date: Date
    let candidate: LookupCandidate.Persisted
    
    init(from item: HistoryItem) {
        query = item.query
        date = item.date
        candidate = item.candidate.persisted
    }
}

struct HistoryItem {
    let query: String
    let candidate: LookupCandidate
    let date: Date

    init(query: String, candidate: LookupCandidate, date: Date? = nil) {
        self.query = query
        self.candidate = candidate
        self.date = date ?? Date()
    }

    init(stringLiteral value: StringLiteralType) {
        self.query = value
        self.candidate = LookupCandidate(service: LookupService(name: "literal"))
        self.date = Date()
    }

}

extension HistoryItem: ExpressibleByStringLiteral {
}

