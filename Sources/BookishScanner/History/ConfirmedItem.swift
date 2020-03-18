// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 16/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol ConfirmedItemRepresentable {
    var name: String? { get }
    var summary: String { get }
    var isbn: String? { get }
    var serviceName: String { get }
    var serviceData: String { get }
}

struct ConfirmedItem: Codable {
    let query: String
    let name: String
    let summary: String?
    let isbn: String?
    let captured: Date
    var service: String
    var raw: String
}

extension ConfirmedItem: ExpressibleByStringLiteral {
    init(query: String, candidate: ConfirmedItemRepresentable) {
        self.query = query
        self.name = candidate.name ?? query
        self.summary = candidate.summary
        self.isbn = candidate.isbn
        self.service = candidate.serviceName
        self.raw = candidate.serviceData
        self.captured = Date()
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.query = value
        self.name = value
        self.summary = ""
        self.isbn = nil
        self.service = "literal"
        self.raw = value
        self.captured = Date()
    }
}

