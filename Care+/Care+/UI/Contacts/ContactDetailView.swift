//
//  ContactDetailView.swift
//  Care+
//

import SwiftUI
import PhotosUI

@MainActor struct ContactDetailView: View {
    @Bindable var state: AppState
    @Binding var contact: ContactItem

    @State private var pickedAvatar: PhotosPickerItem?
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var player = AudioPlayer()
    
    @Environment(\.colorScheme) private var scheme
    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    private var essentialsOK: Bool {
        Validators.nonEmpty(contact.name) &&
        ((contact.phone.map(Validators.isValidPhone) ?? false) || (contact.email.map(Validators.isValidEmail) ?? false))
    }

    var body: some View {
        Screen {
            // Header card
            CardDark {
                HStack(spacing: 14) {
                    // Snapshot to avoid capturing @MainActor-isolated `contact` in a Sendable closure
                    let avatarPhoto = contact.photoData
                    PhotosPicker(selection: $pickedAvatar, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            Avatar(photo: avatarPhoto)
                                .frame(width: 70, height: 70)
                            let todayCount = state.callSummary(for: contact, on: .now).count
                            if todayCount > 0 {
                                Text("\(todayCount)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .offset(x: 4, y: 4)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Name (required)", text: $contact.name)
                            .padding(12)
                            .background(Color.white.opacity(0.12))
                            .foregroundStyle(textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )

                        Text(essentialsOK ? "Valid" : "Missing essentials")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(essentialsOK ? AppTheme.success : AppTheme.danger)
                    }

                    Spacer()

                    if contact.phone != nil {
                        Button {
                            CallHelper.call(contact: contact, state: state)
                        } label: {
                            Image(systemName: "phone.fill")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Circle())
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .accessibilityLabel("Chiama")
                    }
                }
            }

            // ✅ Call stats card
            CardDark {
                let sum = state.callSummary(for: contact, on: .now)

                Text("Calls")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(textPrimary)

                HStack {
                    Text("Today")
                        .foregroundStyle(textSecondary)
                    Spacer()
                    Text("\(sum.count) times")
                        .foregroundStyle(textPrimary)
                        .font(.headline)
                }

                HStack {
                    Text("Last call")
                        .foregroundStyle(textSecondary)
                    Spacer()
                    Text(sum.last?.formatted(.dateTime.hour().minute()) ?? "—")
                        .foregroundStyle(textPrimary)
                        .font(.headline)
                }
            }

            // Audio note
            CardDark {
                Text("Audio note")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(textPrimary)

                HStack(spacing: 10) {
                    Button {
                        recorder.isRecording ? recorder.stop() : recorder.start()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.fill")
                            Text(recorder.isRecording ? "Stop" : "Record")
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(recorder.isRecording ? AppTheme.danger : AppTheme.primary)

                    if let url = contact.audioNoteURL ?? recorder.lastRecordingURL {
                        Button {
                            player.isPlaying ? player.stop() : player.play(url: url)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
                                Text(player.isPlaying ? "Stop" : "Play")
                            }
                            .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.9))

                        Button {
                            contact.audioNoteURL = nil
                            recorder.lastRecordingURL = nil
                            if player.isPlaying { player.stop() }
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(AppTheme.danger)
                    }
                }

                if recorder.lastRecordingURL != nil && contact.audioNoteURL == nil {
                    Button {
                        contact.audioNoteURL = recorder.lastRecordingURL
                        state.saveContacts()
                    } label: {
                        Text("Attach to contact")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.white.opacity(0.18))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            // Details
            CardDark {
                LabeledField(
                    label: "Relationship / Role",
                    placeholder: "e.g. Daughter / Doctor",
                    text: Binding(
                        get: { contact.relation ?? "" },
                        set: { contact.relation = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
                    )
                )

                LabeledField(
                    label: "Phone (valid if no email)",
                    placeholder: "+39 333 123 4567",
                    text: Binding(
                        get: { contact.phone ?? "" },
                        set: { contact.phone = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
                    ),
                    keyboard: .phonePad
                )

                LabeledField(
                    label: "Email (valid if no phone)",
                    placeholder: "name@email.com",
                    text: Binding(
                        get: { contact.email ?? "" },
                        set: { contact.email = $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
                    ),
                    keyboard: .emailAddress
                )

                if !essentialsOK {
                    Text("Required: name + (valid phone OR valid email).")
                        .font(.caption)
                        .foregroundStyle(AppTheme.danger)
                }

                Button {
                    state.saveContacts()
                } label: {
                    Text("Save changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .opacity(essentialsOK ? 1 : 0.45)
                }
                .disabled(!essentialsOK)
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task(id: pickedAvatar) {
            guard let pickedAvatar else { return }
            do {
                if let data = try await pickedAvatar.loadTransferable(type: Data.self) {
                    contact.photoData = data
                    state.saveContacts()
                }
            } catch {}
        }
    }
}

