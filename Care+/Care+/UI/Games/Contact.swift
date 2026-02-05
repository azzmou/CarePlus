import SwiftUI

enum ContactType: String, CaseIterable, Identifiable, Codable {
    case family = "Family"
    case caregiver = "Caregiver"
    case doctor = "Doctor"

    var id: String { rawValue }
    var iconName: String {
        switch self {
        case .family: return "person.2.fill"
        case .caregiver: return "house.fill"
        case .doctor: return "stethoscope"
        }
    }
}

struct Contact: Identifiable, Codable, Equatable {
    let id: UUID
    var type: ContactType
    var firstName: String
    var lastName: String
    var roleDescription: String
    var phoneNumber: String
    var imageName: String? // name of an asset in the catalog
    var voiceNoteURL: URL? // optional local recording

    init(id: UUID = UUID(), type: ContactType, firstName: String, lastName: String, roleDescription: String, phoneNumber: String, imageName: String? = nil, voiceNoteURL: URL? = nil) {
        self.id = id
        self.type = type
        self.firstName = firstName
        self.lastName = lastName
        self.roleDescription = roleDescription
        self.phoneNumber = phoneNumber
        self.imageName = imageName
        self.voiceNoteURL = voiceNoteURL
    }

    var fullName: String { "\(firstName) \(lastName)" }
}
