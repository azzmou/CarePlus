//
//  UserProfile.swift
//  Care+
//
//  User account model
//

import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var phone: String
    var email: String
    var provider: String?   // "apple" / "google" / "email" / "guest"

    init(
        id: UUID = UUID(),
        name: String,
        phone: String,
        email: String,
        provider: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.provider = provider
    }
}
