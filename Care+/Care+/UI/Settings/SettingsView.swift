import SwiftUI

struct SettingsView: View {
    @Bindable var state: AppState
    @Environment(\.colorScheme) private var scheme
    
    private var textPrimary: Color { AppTheme.textPrimary }
    private var textSecondary: Color { AppTheme.textSecondary }
    private var iconColor: Color { AppTheme.primary }

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(AppTheme.primary)
                        Text("Calming reminders")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.primary)
                    }

                    Toggle(
                        "Enabled",
                        isOn: Binding(
                            get: { state.calmingRemindersEnabled },
                            set: { state.setCalmingReminders(enabled: $0) }
                        )
                    )
                    .foregroundStyle(textPrimary)
                    .tint(AppTheme.primary)

                    HStack {
                        Text("Interval")
                            .foregroundStyle(textPrimary)
                        Spacer()

                        // ✅ Allow 1-minute interval
                        Stepper(
                            value: Binding(
                                get: { state.calmingIntervalMinutes },
                                set: { state.setCalmingInterval(minutes: $0) }
                            ),
                            in: 1...120,
                            step: 1
                        ) {
                            Text("\(state.calmingIntervalMinutes) min")
                                .foregroundStyle(textPrimary)
                        }
                        .tint(AppTheme.primary)
                    }

                    Text("We’ll send gentle reminders to calm and refocus.")
                        .font(.footnote)
                        .foregroundStyle(textSecondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

