import Foundation

enum ChatSender: String, Codable, Hashable {
    case user
    case caregiver
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let sender: ChatSender
    let text: String
    let date: Date

    init(id: UUID = UUID(), sender: ChatSender, text: String, date: Date = .now) {
        self.id = id
        self.sender = sender
        self.text = text
        self.date = date
    }
}
