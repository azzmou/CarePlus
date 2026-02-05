//
//  CallEvent.swift
//  Care+
//
//  Logged outgoing call (from app)
//

import Foundation

struct CallEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let contactKey: String     // ContactItem.uniqueKey
    let timestamp: Date

    init(
        id: UUID = UUID(),
        contactKey: String,
        timestamp: Date = .now
    ) {
        self.id = id
        self.contactKey = contactKey
        self.timestamp = timestamp
    }
}
