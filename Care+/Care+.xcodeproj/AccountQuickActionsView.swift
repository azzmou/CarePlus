import SwiftUI

struct AccountQuickActionsView: View {
    @Environment(\.colorScheme) private var scheme

    @Bindable var state: AppState
    var onClose: () -> Void
    var onOpenAccount: () -> Void

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 14) {
                card {
                    actionRow(title: "Account", systemImage: "person.crop.circle") {
                        onOpenAccount()
                    }

                    Divider().overlay(Color.white.opacity(0.12))

                    actionRow(title: "Logout", systemImage: "arrow.right.square") {
                        state.logout()
                        onClose()
                    }
                }
            }
            .padding(18)
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(scheme == .dark ? Color.white.opacity(0.06) : Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func actionRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 28, height: 28, alignment: .center)

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(textPrimary)

                Spacer()
            }
            .contentShape(Rectangle())
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let state = AppState()
    state.load()
    return AccountQuickActionsView(state: state, onClose: {}, onOpenAccount: {})
}
