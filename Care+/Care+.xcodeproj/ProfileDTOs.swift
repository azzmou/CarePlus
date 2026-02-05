import Foundation

public struct ProfileUpsertDTO: Encodable, Sendable {
    public let id: String
    public var first_name: String?
    public var last_name: String?
    public var phone: String?
    public var role: String?
    public var display_name: String?
    public var email: String?

    public init(id: String,
                first_name: String? = nil,
                last_name: String? = nil,
                phone: String? = nil,
                role: String? = nil,
                display_name: String? = nil,
                email: String? = nil) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.phone = phone
        self.role = role
        self.display_name = display_name
        self.email = email
    }
}

public struct CaregiverUpsertDTO: Encodable, Sendable {
    public let user_id: String
    public let first_name: String
    public let last_name: String
    public let relationship: String
    public let phone: String
    public let email: String

    public init(user_id: String, first_name: String, last_name: String, relationship: String, phone: String, email: String) {
        self.user_id = user_id
        self.first_name = first_name
        self.last_name = last_name
        self.relationship = relationship
        self.phone = phone
        self.email = email
    }
}
