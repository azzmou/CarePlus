import SwiftUI

struct EducationOnboardingCompactView: View {
    @Bindable var state: AppState

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        infoCard(title: "What is dementia and Alzheimer’s?", text: "Dementia is a group of symptoms that affect memory, thinking, and social abilities. Alzheimer’s is the most common cause of dementia.")

                        infoCard(title: "How Care+ helps", text: "Stay on top of daily life with reminders and simple tools. Care+ supports both patients and caregivers.")

                        infoCard(title: "Tasks & medication reminders", text: "Create tasks and medication schedules. Get gentle notifications to remember important things.")

                        infoCard(title: "Daily diary", text: "Capture moments with text, photos, videos, or voice notes. Look back at your day easily.")

                        infoCard(title: "Contacts & quick calls", text: "Keep important people close. Call them quickly from the app.")

                        infoCard(title: "Memory exercises", text: "Practice simple games designed to support memory and attention.")

                        infoCard(title: "Caregiver support", text: "Caregivers can help organize tasks, track progress, and stay connected with the patient.")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 40)
                    .padding(.bottom, 120)
                }

                HStack(spacing: 12) {
                    Button("Skip") { complete() }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(AppTheme.surface)
                        .foregroundStyle(AppTheme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button("Continue") { complete() }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(16)
                .background(LinearGradient(colors: [AppTheme.background.opacity(0.0), AppTheme.background], startPoint: .top, endPoint: .bottom))
            }
            .navigationTitle("")
            .toolbarTitleDisplayMode(.inline)
        }
    }

    private func complete() {
        state.setEducationSeen()
    }

    private func infoCard(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

