import SwiftUI

struct RoundedTextField: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool

    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self._text = text
        self.isSecure = isSecure
    }

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                    .padding(12)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AppTheme.textPrimary)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                    .padding(12)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.separator, lineWidth: 1)
        )
    }
}

#Preview {
    StatefulPreview()
}

private struct StatefulPreview: View {
    @State private var plain = ""
    @State private var secure = ""

    var body: some View {
        VStack(spacing: 16) {
            RoundedTextField("Email", text: $plain)
            RoundedTextField("Password", text: $secure, isSecure: true)
        }
        .padding()
        .background(AppTheme.background)
    }
}
