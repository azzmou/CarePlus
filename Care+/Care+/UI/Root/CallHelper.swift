import Foundation
import UIKit

public struct CallHelper {
    /// Normalizes a phone number to digits only (e.g., "+39 333-123" -> "39333123").
    public static func normalizedDigits(_ s: String) -> String {
        s.filter(\.isNumber)
    }

    /// Place a call to a specific contact using existing app state logging, warning if already called 2+ times today.
    static func call(contact: ContactItem, state: AppState) {
        // If we have a phone, warn on 3rd+ call today
        if let phone = contact.phone, !phone.isEmpty {
            let summary = state.callSummary(for: contact, on: .now)
            if summary.count >= 2 { // 2 calls already -> this tap is the 3rd
                NotificationManager.scheduleRepeatCallWarning(for: contact.name, phone: phone)
            }
        }
        // Delegate to existing app logic (logs + opens tel:)
        state.logAndCall(contact)
    }

    /// Attempts to dial a raw number string. If it matches a known contact by digits, use `call(contact:)` to keep logging.
    static func dial(raw input: String, state: AppState) {
        let digits = normalizedDigits(input)
        guard !digits.isEmpty else { return }

        // Try to find a matching contact by digits-only comparison
        if let match = state.contacts.first(where: { c in
            if let p = c.phone { return normalizedDigits(p) == digits } else { return false }
        }) {
            call(contact: match, state: state)
            return
        }

        // Fallback: open tel:// directly
        if let url = URL(string: "tel://\(digits)") {
            DispatchQueue.main.async { UIApplication.shared.open(url) }
        }
    }
}
