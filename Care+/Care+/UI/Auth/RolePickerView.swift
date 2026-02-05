import SwiftUI

struct RolePickerView: View {
    @Bindable var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack(spacing: 24) {
                    Text("Who are you?")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    VStack(spacing: 16) {
                        roleButton(
                            title: "User (Patient)",
                            subtitle: "Use the app as a patient",
                            systemImage: "person.fill",
                            action: { state.selectedRole = .user }
                        )
                        roleButton(
                            title: "Caregiver",
                            subtitle: "Manage and assist the patient",
                            systemImage: "heart.text.square.fill",
                            action: { state.selectedRole = .caregiver }
                        )
                    }
                    .padding(.horizontal)

                    Spacer()

                    Text("Your role choice isn't saved and will be requested at every login.")
                        .font(.footnote)
                        .foregroundStyle(textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Role")
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func roleButton(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background((scheme == .dark ? Color.white.opacity(0.12) : AppTheme.lavenderButtonLight.opacity(0.35)))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(Color.white)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(scheme == .dark ? Color.white.opacity(0.18) : AppTheme.iconLight.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RolePickerView(state: AppState())
}
