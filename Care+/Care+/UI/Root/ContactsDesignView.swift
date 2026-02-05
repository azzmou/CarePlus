import SwiftUI
import UIKit
import Combine
import PhotosUI

struct ContactsDesignView: View {
    @Bindable var state: AppState
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showAddContactSheet = false
    @State private var editingContact: ContactItem? = nil
    @State private var isEditingPresented: Bool = false
    @State private var playingURL: URL? = nil
    @State private var recordingContactID: UUID? = nil
    @State private var isRecordingSheetPresented: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var photoPickerContactID: UUID? = nil
    @State private var photoPickerItem: PhotosPickerItem? = nil

    private enum PickerContext { case doctor, caregiver, family }
    @State private var pickerContext: PickerContext? = nil
    @State private var showContactPicker: Bool = false

    @Environment(\.colorScheme) private var scheme
    private var textPrimary: Color { AppTheme.textPrimary }
    private var textSecondary: Color { AppTheme.textSecondary }
    private var iconColor: Color { AppTheme.primary }

    private var doctorContact: ContactItem? {
        state.contacts.first(where: { $0.isDoctor })
    }

    private var caregiverContacts: [ContactItem] {
        state.contacts.filter { $0.isCaregiver }
    }

    private var familyContacts: [ContactItem] {
        let filtered = state.contacts.filter { contact in
            let r = (contact.relation ?? "").lowercased()
            return !contact.isCaregiver && !contact.isDoctor &&
                   (r.contains("family") || r.contains("daughter") || r.contains("son"))
        }
        if !filtered.isEmpty {
            return filtered
        } else {
            // fallback: all non-caregiver and non-doctor contacts
            return state.contacts.filter { contact in
                let r = (contact.relation ?? "").lowercased()
                return !r.contains("caregiver") && !r.contains("doctor")
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    emergencyCardSection

                    Text("Contacts: \(state.contacts.count)")
                        .font(.caption)
                        .foregroundStyle(textSecondary)

                    if state.contacts.isEmpty {
                        importButton
                    }

                    doctorSection

                    primaryCaregiverSection

                    contactSection(title: "Family", icon: "heart.fill", contacts: familyContacts)

                    addNewContactButton.padding(.top, 10)
                    Spacer(minLength: 120)
                }
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddContactSheet) {
                AddContactView(state: state, onAdd: { newContact in
                    state.upsertContact(newContact)
                })
            }
        }
        .sheet(item: $editingContact) { contact in
            EditContactView(state: state, contact: contact, onSave: { updated in
                if let idx = state.contacts.firstIndex(where: { $0.id == updated.id }) {
                    state.contacts[idx] = updated
                    state.saveContacts()
                }
            })
        }
        .sheet(isPresented: $isRecordingSheetPresented) {
            if let id = recordingContactID, let contact = state.contacts.first(where: { $0.id == id }) {
                RecordContactVoiceView(contact: contact, onSave: { savedURL in
                    if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                        state.contacts[idx].audioNoteURL = savedURL
                        state.saveContacts()
                    }
                    isRecordingSheetPresented = false
                }, onCancel: {
                    isRecordingSheetPresented = false
                }, onRemove: {
                    if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                        state.contacts[idx].audioNoteURL = nil
                        state.saveContacts()
                    }
                    isRecordingSheetPresented = false
                })
            } else {
                Text("No contact selected")
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                    Text("Select a photo")
                        .font(.headline)
                }
                .padding()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showContactPicker) {
            VStack(alignment: .leading) {
                HStack {
                    Text(pickerContext == .doctor ? "Select a doctor" : (pickerContext == .caregiver ? "Select a caregiver" : "Select a family contact"))
                        .font(.headline)
                    Spacer()
                    Button("Close") { showContactPicker = false }
                        .font(.subheadline)
                }
                .padding()

                List(filteredContactsForPicker(), id: \.id) { contact in
                    Button {
                        applySelection(contact)
                        showContactPicker = false
                    } label: {
                        HStack(spacing: 12) {
                            Avatar(photo: contact.photoData)
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name)
                                    .font(.subheadline.weight(.semibold))
                                Text(contact.relation ?? contact.phone ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .presentationDetents([.medium, .large])
        }
        .task(id: photoPickerItem) {
            guard let item = photoPickerItem else { return }
            do {
                if let data = try await item.loadTransferable(type: Data.self), let id = photoPickerContactID, let idx = state.contacts.firstIndex(where: { $0.id == id }) {
                    state.contacts[idx].photoData = data
                    state.saveContacts()
                }
            } catch {
                // ignore errors silently
            }
            showPhotoPicker = false
            photoPickerItem = nil
            photoPickerContactID = nil
        }
    }
}

private extension ContactsDesignView {
    func setPrimaryCaregiver(_ c: ContactItem) {
        if let index = state.contacts.firstIndex(where: { $0.id == c.id }) {
            let currentlySet = state.contacts[index].isCaregiver
            for i in state.contacts.indices {
                state.contacts[i].isCaregiver = false
            }
            // Toggle off if already true, else set true
            state.contacts[index].isCaregiver = !currentlySet
            state.saveContacts()
        }
    }

    func setPrimaryDoctor(_ c: ContactItem) {
        if let index = state.contacts.firstIndex(where: { $0.id == c.id }) {
            let currentlySet = state.contacts[index].isDoctor
            for i in state.contacts.indices {
                state.contacts[i].isDoctor = false
            }
            // Toggle off if already true, else set true
            state.contacts[index].isDoctor = !currentlySet
            state.saveContacts()
        }
    }

    func filteredContactsForPicker() -> [ContactItem] {
        switch pickerContext {
        case .doctor:
            // Prefer non-doctor contacts to pick from, but allow all
            return state.contacts
        case .caregiver:
            return state.contacts
        case .family:
            // Family are those not doctor/caregiver
            return state.contacts.filter { !$0.isDoctor && !$0.isCaregiver }
        case .none:
            return state.contacts
        }
    }

    func applySelection(_ contact: ContactItem) {
        switch pickerContext {
        case .doctor:
            // Clear others and set this as doctor
            for i in state.contacts.indices { state.contacts[i].isDoctor = false }
            if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                state.contacts[idx].isDoctor = true
                state.saveContacts()
            }
        case .caregiver:
            // Clear others and set this as caregiver
            for i in state.contacts.indices { state.contacts[i].isCaregiver = false }
            if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                state.contacts[idx].isCaregiver = true
                state.saveContacts()
            }
        case .family:
            // Ensure not doctor/caregiver so it appears in Family section
            if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                state.contacts[idx].isDoctor = false
                state.contacts[idx].isCaregiver = false
                state.saveContacts()
            }
        case .none:
            break
        }
    }

    var topBar: some View {
        HStack {
            NavigationLink {
                SettingsView(state: state)
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
            }

            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Spacer()

            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }, label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.trailing, 10)
            })
        }
        .padding(.vertical, 6)
    }

    var emergencyCardSection: some View {
        CardDark {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "phone.bubble.left.fill")
                            .font(.headline)
                            .foregroundStyle(iconColor)
                        Text("Contacts")
                            .font(.headline)
                            .foregroundStyle(iconColor)
                    }
                    Text("Emergency SOS")
                        .font(.caption)
                        .foregroundStyle(textSecondary)
                }

                if let sos = state.sosContact {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sos.name).font(.title2.bold()).foregroundStyle(textPrimary)
                            Text(sos.relation ?? "Primary Emergency Contact").font(.caption).foregroundStyle(textSecondary)
                        }
                        Spacer()
                        Button {
                            CallHelper.call(contact: sos, state: state)
                        } label: {
                            Image(systemName: "phone.fill")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 70)
                                .background(Circle().fill(AppTheme.warning))
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        plusCircleButton {
                            // Open add contact sheet or just haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            showAddContactSheet = true
                        }
                        Spacer()
                    }
                    .padding(.vertical, 15)
                }
            }
        }
    }

    var importButton: some View {
        Button {
            ContactsImportService.importFromDevice(existing: state.contacts) { imported in
                guard !imported.isEmpty else { return }
                var toAppend: [ContactItem] = []
                for c in imported {
                    let phoneC = (c.phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let nameC = c.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let exists = state.contacts.contains { existing in
                        let phoneE = (existing.phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        let nameE = existing.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        if !phoneC.isEmpty && phoneE == phoneC { return true }
                        return !phoneC.isEmpty && nameE == nameC && phoneE == phoneC
                    }
                    if !exists { toAppend.append(c) }
                }
                if !toAppend.isEmpty {
                    state.contacts.append(contentsOf: toAppend)
                    state.saveContacts()
                }
                print("Imported contacts count: \(state.contacts.count)")
            }
        } label: {
            Label("Import from device", systemImage: "arrow.down.doc.fill")
                .font(.subheadline.bold()).foregroundStyle(AppTheme.primary)
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(AppTheme.primary.opacity(0.1)).cornerRadius(12)
        }
    }

    func contactSection(title: String, icon: String, contacts: [ContactItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                Spacer()
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    pickerContext = .family
                    showContactPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(iconColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 5)
            CardDark {
                if contacts.isEmpty {
                    Text("No \(title.lowercased()) yet.")
                        .font(.subheadline)
                        .foregroundStyle(textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(contacts.enumerated()), id: \.element.id) { idx, contact in
                            contactRow(contact)
                            if idx < contacts.count - 1 {
                                Divider().background(Color.white.opacity(0.1)).padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
        }
    }

    var caregiverSection: some View {
        contactSection(title: "Caregiver", icon: "staroflife.fill", contacts: caregiverContacts)
    }

    var doctorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Doctor")
                    .font(.headline)
                    .foregroundStyle(iconColor)
                Spacer()
            }
            .padding(.horizontal, 5)
            CardDark {
                if let doctor = doctorContact {
                    contactRow(doctor)
                } else {
                    VStack(spacing: 10) {
                        Text("No doctor selected.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textOnDarkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)

                        HStack {
                            Spacer()
                            plusCircleButton {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                pickerContext = .doctor
                                showContactPicker = true
                            }
                            Spacer()
                        }
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    var primaryCaregiverSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Caregiver")
                    .font(.headline)
                    .foregroundStyle(iconColor)
                Spacer()
            }
            .padding(.horizontal, 5)
            CardDark {
                if let primary = caregiverContacts.first {
                    contactRow(primary)
                } else {
                    VStack(spacing: 10) {
                        Text("No caregiver selected.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textOnDarkSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)

                        HStack {
                            Spacer()
                            plusCircleButton {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                pickerContext = .caregiver
                                showContactPicker = true
                            }
                            Spacer()
                        }
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }

    func contactRow(_ contact: ContactItem) -> some View {
        Button(action: {
            editingContact = contact
        }, label: {
            HStack(spacing: 15) {
                Avatar(photo: contact.photoData)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name).font(.headline).foregroundStyle(textPrimary)
                            Text(contact.relation ?? "").font(.caption).foregroundStyle(textSecondary)
                        }
                        Spacer()
                        Menu {
                            Button { setPrimaryCaregiver(contact) } label: { Label("Set as Caregiver", systemImage: "person.2.fill") }
                            Button { setPrimaryDoctor(contact) } label: { Label("Set as Doctor", systemImage: "stethoscope") }
                            Button { state.setSOSContact(contact) } label: { Label("Set as Emergency SOS", systemImage: "star.fill") }
                            Button {
                                photoPickerContactID = contact.id
                                showPhotoPicker = true
                            } label: { Label("Add/Change photo", systemImage: "photo") }
                            Button { recordingContactID = contact.id; isRecordingSheetPresented = true } label: { Label("Record voice", systemImage: "mic.fill") }
                            if contact.audioNoteURL != nil {
                                Button(role: .destructive) {
                                    if let idx = state.contacts.firstIndex(where: { $0.id == contact.id }) {
                                        state.contacts[idx].audioNoteURL = nil
                                        state.saveContacts()
                                    }
                                } label: { Label("Remove voice", systemImage: "trash") }
                            }
                            Button { editingContact = contact } label: { Label("Edit", systemImage: "pencil") }
                            Button(role: .destructive) { state.contacts.removeAll { $0.id == contact.id }; state.saveContacts() } label: { Label("Delete", systemImage: "trash") }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(AppTheme.primary)
                                .padding(8)
                        }
                    }
                    Button(action: {
                        CallHelper.call(contact: contact, state: state)
                    }, label: {
                        Label("Call", systemImage: "phone.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppTheme.success)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    })
                    Button {
                        if let url = contact.audioNoteURL {
                            if playingURL == url {
                                audioPlayer.stop()
                                playingURL = nil
                            } else {
                                audioPlayer.play(url: url)
                                playingURL = url
                            }
                        }
                    } label: {
                        Label("Listen voice", systemImage: playingURL == contact.audioNoteURL ? "stop.fill" : "speaker.wave.2.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(AppTheme.primary)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .disabled(contact.audioNoteURL == nil)
                    .opacity(contact.audioNoteURL == nil ? 0.4 : 1.0)
                }
            }
        })
        .buttonStyle(.plain)
    }

    var addNewContactButton: some View {
        Button(action: { showAddContactSheet = true }, label: {
            HStack {
                Image(systemName: "plus").font(.title2.weight(.bold))
                Text("Add a new contact").font(.headline)
                Spacer()
            }
            .padding()
            .background(AppTheme.primary)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        })
    }
    
    func plusCircleButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(AppTheme.primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    func voicePill(contact: ContactItem) -> some View {
        let isPlaying = playingURL == contact.audioNoteURL

        return Button {
            guard let url = contact.audioNoteURL else { return }
            if isPlaying {
                audioPlayer.stop()
                playingURL = nil
            } else {
                audioPlayer.stop()
                audioPlayer.play(url: url)
                playingURL = url
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(isPlaying ? AppTheme.primary : AppTheme.primary.opacity(0.85))
                    .clipShape(Circle())

                Text(contact.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(textPrimary)

                Spacer()

                if isPlaying {
                    Image(systemName: "waveform")
                        .foregroundStyle(AppTheme.primary)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(
                Group {
                    if scheme == .dark {
                        Color.white.opacity(0.08)
                    } else {
                        AppTheme.surface.opacity(0.9)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        scheme == .dark ? Color.white.opacity(0.10) : AppTheme.primary.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var listenVoiceCard: some View {
        CardDark {
            VStack(alignment: .leading, spacing: 10) {
                Text("Voice Notes")
                    .font(.headline)
                    .foregroundStyle(iconColor)
                    .padding(.leading, 8)

                if state.contacts.allSatisfy({ $0.audioNoteURL == nil }) {
                    VStack {
                        Text("No recordings available")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
                            .padding(.top, 8)
                        Spacer(minLength: 0)
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(state.contacts.filter { $0.audioNoteURL != nil }, id: \.id) { contact in
                                voicePill(contact: contact)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

import AVFoundation
struct RecordContactVoiceView: View {
    let contact: ContactItem
    let onSave: (URL) -> Void
    let onCancel: () -> Void
    let onRemove: () -> Void

    @StateObject private var recorder = ContactAudioRecorder()
    @State private var isRecording = false
    @State private var savedURL: URL? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Record voice for \(contact.name)")
                    .font(.title3.weight(.semibold))

                Spacer()

                Button(action: toggleRecording) {
                    VStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 72))
                        Text(isRecording ? "Stop" : "Start Recording")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if let url = savedURL {
                    Text("Recorded: \(url.lastPathComponent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack {
                    Button(role: .cancel, action: { onCancel() }) {
                        Text("Cancel")
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    if contact.audioNoteURL != nil {
                        Button(role: .destructive, action: { onRemove() }) { Text("Remove") }
                    }
                    Button(action: {
                        if let url = savedURL {
                            onSave(url)
                        } else {
                            // Ifsi v not explicitly saved after a stop, stop and save now
                            Task { await finalizeRecordingAndSave() }
                        }
                    }) { Text("Save") }
                    .disabled(isRecording)
                }
                .font(.headline)
            }
            .padding()
        }
        .onDisappear {
            if isRecording { recorder.stopRecording() }
        }
    }

    private func toggleRecording() {
        if isRecording {
            let url = recorder.stopRecording()
            savedURL = url
            isRecording = false
        } else {
            Task {
                let filename = "contact_\(contact.id.uuidString).m4a"
                if await recorder.startRecording(fileName: filename) != nil {
                    savedURL = nil
                    isRecording = true
                }
            }
        }
    }

    private func finalizeRecordingAndSave() async {
        if isRecording {
            let url = recorder.stopRecording()
            isRecording = false
            savedURL = url
        }
        if let url = savedURL {
            onSave(url)
        }
    }
}

final class ContactAudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?

    @MainActor
    func startRecording(fileName: String) async -> URL? {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return nil
        }

        let granted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
        guard granted else { return nil }

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            return url
        } catch {
            return nil
        }
    }

    func stopRecording() -> URL? {
        let url = recorder?.url
        recorder?.stop()
        recorder = nil
        return url
    }
}

