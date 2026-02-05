//
//  ContactItem.swift
//  Care+
//
//  Internal contact model
//

import Foundation

struct ContactItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var relation: String?      // ruolo (figlio, medico, ecc.)
    var phone: String?
    var email: String?
    var photoData: Data?
    var audioNoteURL: URL?
    var isCaregiver: Bool = false
    var isDoctor: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        relation: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        photoData: Data? = nil,
        audioNoteURL: URL? = nil,
        isCaregiver: Bool = false,
        isDoctor: Bool = false
    ) {
        self.id = id
        self.name = name
        self.relation = relation
        self.phone = phone
        self.email = email
        self.photoData = photoData
        self.audioNoteURL = audioNoteURL
        self.isCaregiver = isCaregiver
        self.isDoctor = isDoctor
    }

    /// Unique key: NAME + ROLE (case insensitive)
    var uniqueKey: String {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let r = (relation ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(n)||\(r)"
    }
}
