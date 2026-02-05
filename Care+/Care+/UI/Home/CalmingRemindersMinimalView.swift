import SwiftUI

struct CalmingRemindersMinimalView: View {
    @Bindable var state: AppState
    @State private var enabled: Bool = false
    @State private var interval: Double = 20

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    Text("Calming reminders")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textOnDarkPrimary)
                    
                    Text("Stato")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textOnDarkSecondary)

                    Toggle("Enable reminders", isOn: $enabled)
                        .tint(AppTheme.accentTeal)
                        .foregroundStyle(AppTheme.textOnDarkPrimary)
                    
                    Text("Intervallo")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textOnDarkSecondary)

                    HStack {
                        Text("Interval: \(Int(interval)) min")
                            .foregroundStyle(AppTheme.textOnDarkPrimary.opacity(0.9))
                        Spacer()
                    }

                    Text("Regolazione")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textOnDarkSecondary)

                    Slider(value: $interval, in: 5...120, step: 5)
                        .tint(AppTheme.accentTeal)
                    
                    Text("Azione")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textOnDarkSecondary)

                    Button {
                        if enabled {
                            NotificationManager.requestAuthorization()
                            NotificationManager.cancelCalmingReminders()
                            NotificationManager.scheduleCalmingReminders(intervalMinutes: Int(interval), startNow: true)
                        } else {
                            NotificationManager.cancelCalmingReminders()
                        }
                    } label: {
                        Text("Apply")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(AppTheme.warningYellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Calming")
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

