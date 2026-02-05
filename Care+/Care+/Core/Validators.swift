//
//  Validators.swift
//  Care+
//
//  Input validation helpers
//

import Foundation

enum Validators {

    static func nonEmpty(_ s: String) -> Bool {
        !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func isValidEmail(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return false }

        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return t.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPhone(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return false }

        // Allow only digits, spaces, dashes, parentheses, and an optional leading plus.
        // This checks the overall allowed character set and rough length.
        let allowedPattern = #"^\+?[0-9\s\-\(\)]{8,20}$"#
        guard t.range(of: allowedPattern, options: .regularExpression) != nil else { return false }

        // Count digits to ensure the phone has a realistic length (E.164 recommends up to 15 digits).
        let digits = t.filter(\.isNumber)
        return digits.count >= 8 && digits.count <= 15
    }
}
