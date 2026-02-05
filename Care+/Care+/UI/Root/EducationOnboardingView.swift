import SwiftUI

struct EducationOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome to Care+")
                                .font(.largeTitle.bold())
                                .foregroundStyle(textPrimary)
                            Text("A quick guide about dementia and Alzheimer’s, and how the app can help you and your caregiver.")
                                .font(.subheadline)
                                .foregroundStyle(textSecondary)
                        }

                        CardDark {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundStyle(iconColor)
                                    Text("What are dementia and Alzheimer’s")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                }

                                Text("Dementia is a group of symptoms that affect memory, thinking, language, and the ability to carry out daily activities. Alzheimer’s disease is the most common cause of dementia.")
                                    .foregroundStyle(textPrimary)
                                    .font(.callout)

                                Text("Early stages may include mild forgetfulness, difficulty finding words, or organizing tasks. In the middle stage, symptoms become more noticeable: increased confusion, assistance needed for daily activities, and mood changes.")
                                    .foregroundStyle(textPrimary)
                                    .font(.callout)
                            }
                        }

                        CardDark {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundStyle(iconColor)
                                    Text("How Care+ can help")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    bullet("Tasks and medication reminders", detail: "Manage tasks and medication with notifications and reminders.")
                                    bullet("Daily diary", detail: "Capture thoughts, photos, videos, and voice notes to preserve meaningful moments.")
                                    bullet("Contacts and quick calls", detail: "Add contacts with photos and audio; call favorites and keep track of calls.")
                                    bullet("Memory games", detail: "Train memory with simple and fun targeted exercises.")
                                    bullet("Simple stats", detail: "Monitor habits and progress to better understand trends.")
                                }
                            }
                        }

                        CardDark {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundStyle(iconColor)
                                    Text("Caregiver support")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                }

                                Text("Care+ is designed for caregivers too: shareable reminders, organized information, and simple tools to reduce everyday stress.")
                                    .foregroundStyle(textPrimary)
                                    .font(.callout)

                                VStack(alignment: .leading, spacing: 8) {
                                    bullet("Organization", detail: "Keep tasks, medications, and contacts in one place.")
                                    bullet("Communication", detail: "Record voice notes or add photos to help recognize loved ones.")
                                    bullet("Safety", detail: "Set an SOS contact for quick access in emergencies.")
                                }
                            }
                        }

                        VStack(spacing: 12) {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                state.setEducationSeen()
                                dismiss()
                            } label: {
                                Text("Get started")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .background(scheme == .dark ? Color.white.opacity(0.92) : AppTheme.lavenderButtonLight)
                                    .foregroundStyle(scheme == .dark ? .black : AppTheme.iconLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Button {
                                if let url = URL(string: "https://www.alz.org/it/dementia-alzheimers-italy") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "link")
                                    Text("Learn more about dementia and Alzheimer’s")
                                }
                                .font(.subheadline)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(textPrimary)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EmptyView()
                }
            }
        }
    }

    private func bullet(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.headline)
                .foregroundStyle(iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(textPrimary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(textSecondary)
            }
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State var state = AppState()
        var body: some View {
            EducationOnboardingView(state: state)
        }
    }
    return Wrapper()
}

