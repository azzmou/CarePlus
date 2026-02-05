import SwiftUI

struct RemindersView: View {
    @Environment(\.colorScheme) private var scheme
    @Bindable var state: AppState

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    private let allowedIntervals: [Int] = [1, 2, 3, 5, 10, 15, 20, 30, 45, 60]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        CardDark {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "bell")
                                        .font(.headline)
                                        .foregroundStyle(iconColor)
                                    Text("Calming reminders")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                }

                                Toggle(isOn: Binding(
                                    get: { state.calmingRemindersEnabled },
                                    set: { newValue in
                                        state.setCalmingReminders(enabled: newValue)
                                        if newValue {
                                            NotificationManager.requestAuthorization()
                                            NotificationManager.cancelCalmingReminders()
                                            NotificationManager.scheduleCalmingReminders(intervalMinutes: state.calmingIntervalMinutes, startNow: true)
                                        } else {
                                            NotificationManager.cancelCalmingReminders()
                                        }
                                    }
                                )) {
                                    Text(state.calmingRemindersEnabled ? "Enabled" : "Disabled")
                                        .foregroundStyle(state.calmingRemindersEnabled ? textPrimary : textSecondary)
                                }
                                .tint(AppTheme.primary)

                                if state.calmingRemindersEnabled {
                                    HStack {
                                        Text("Interval")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(textSecondary)
                                        Spacer()
                                        Menu {
                                            ForEach(allowedIntervals, id: \.self) { m in
                                                Button("\(m) min") {
                                                    state.setCalmingInterval(minutes: m)
                                                    NotificationManager.cancelCalmingReminders()
                                                    NotificationManager.scheduleCalmingReminders(intervalMinutes: m, startNow: true)
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text("\(state.calmingIntervalMinutes) min")
                                                    .foregroundStyle(textPrimary)
                                                Image(systemName: "chevron.down")
                                                    .foregroundStyle(textSecondary)
                                            }
                                            .padding(.horizontal, 12)
                                            .frame(height: 36)
                                            .background(scheme == .dark ? Color.white.opacity(0.12) : AppTheme.iconLight.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        }
                                    }

                                    Button {
                                        NotificationManager.cancelCalmingReminders()
                                        NotificationManager.scheduleCalmingReminders(intervalMinutes: state.calmingIntervalMinutes, startNow: true)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        Text("Reschedule now")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity, minHeight: 44)
                                            .background(AppTheme.primary)
                                            .foregroundStyle(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RemindersView(state: AppState())
}
