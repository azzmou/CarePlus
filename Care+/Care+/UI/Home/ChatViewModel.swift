import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draftText: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Seed with a couple of mock messages
        messages = [
            ChatMessage(sender: .caregiver, text: "Hello! How are you feeling today?"),
            ChatMessage(sender: .user, text: "All good thanks!")
        ]
    }

    func send() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let msg = ChatMessage(sender: .user, text: trimmed)
        messages.append(msg)
        draftText = ""
        simulateCaregiverReplyIfNeeded()
    }

    private func simulateCaregiverReplyIfNeeded() {
        // Simple demo reply after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            let reply = ChatMessage(sender: .caregiver, text: "I understand. Do you want me to remind you of something later?")
            self.messages.append(reply)
        }
    }
}
