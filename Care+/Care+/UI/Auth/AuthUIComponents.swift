import SwiftUI

struct PrimaryPillButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(AppTheme.primary)
        .clipShape(Capsule())
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

struct SecondaryPillButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(AppTheme.primary.opacity(0.08))
        .overlay(
            Capsule().stroke(AppTheme.primary.opacity(0.35), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(AppTheme.textSecondary.opacity(0.15), lineWidth: 1)
        )
    }
}
