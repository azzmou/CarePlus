import SwiftUI
import Contacts
import AVFoundation
import UserNotifications
import UIKit
import UniformTypeIdentifiers
#if canImport(PDFKit)
import PDFKit
#endif

struct OnboardingPermissionsView: View {
    @Bindable var state: AppState
    @State private var contactsStatus: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    @State private var micStatus: AVAudioSession.RecordPermission = AVAudioSession.sharedInstance().recordPermission
    @State private var cameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var notificationsStatus: UNAuthorizationStatus = .notDetermined
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isPresentingContactPicker: Bool = false
    @State private var deviceContacts: [CNContact] = []
    @State private var selectedContactIdentifiers: Set<String> = []
    @State private var isImportingAll: Bool = false
    @State private var isImportingSelection: Bool = false

    @State private var isPresentingMedicalDocPicker: Bool = false
    @State private var medicalReportImportStatus: String = "Not imported"
    @State private var medicalReportTextPreview: String = ""

    @Environment(\.colorScheme) private var scheme
    private var textPrimary: Color { scheme == .dark ? AppTheme.textPrimary : AppTheme.textPrimary }
    private var textSecondary: Color { scheme == .dark ? AppTheme.textSecondary : AppTheme.textSecondary }
    private var iconColor: Color { scheme == .dark ? AppTheme.primary : AppTheme.primary }

    private var pageTitle: String {
        switch currentPage {
        case 0: return "Welcome"
        case 1: return "Contacts"
        case 2: return "Microphone"
        case 3: return "Camera"
        case 4: return "Notifications"
        case 5: return "Medical Report"
        case 6: return "Completion"
        default: return "Onboarding"
        }
    }

    // Robust display name builder for contacts
    private func displayName(for c: CNContact) -> String {
        // Try formatted full name first
        if let formatted = CNContactFormatter.string(from: c, style: .fullName) {
            let trimmed = formatted.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        // Fallback: composed from given + family name
        let given = c.givenName.trimmingCharacters(in: .whitespacesAndNewlines)
        let family = c.familyName.trimmingCharacters(in: .whitespacesAndNewlines)
        let composed = [given, family].filter { !$0.isEmpty }.joined(separator: " ")
        if !composed.isEmpty { return composed }
        // Fallback: phone number
        if let phone = c.phoneNumbers.first?.value.stringValue, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return phone
        }
        // Fallback: email address
        if let email = c.emailAddresses.first.map({ String($0.value) }), !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return email
        }
        // Ultimate fallback
        return "Contact"
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .bottom) {
                    AppBackground()

                    HStack(spacing: 0) {
                        // Page 0 - Welcome
                        Screen {
                            CardDark {
                                HStack(spacing: 10) {
                                    Image(systemName: "hand.raised.fill").foregroundStyle(iconColor)
                                    Text("Welcome")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                }

                                Text("Let's set up a few permissions to get the best experience.")
                                    .foregroundStyle(textPrimary)
                                    .padding(.top, 4)
                            }
                            Button {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                                    currentPage = min(currentPage + 1, 6)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Continue")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(AppTheme.primary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: width)

                        // Page 1 - Contacts
                        Screen {
                            permissionCard(
                                title: "Contacts",
                                icon: "person.crop.circle.badge.plus",
                                statusText: contactStatusText,
                                isGranted: contactsStatus == .authorized,
                                requestAction: requestContacts
                            )
                            if !state.hasImportedDeviceContacts {
                                VStack(spacing: 10) {
                                    Button {
                                        importAllContacts()
                                    } label: {
                                        Text("Import all contacts")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity, minHeight: 44)
                                            .background(contactsStatus == .authorized ? AppTheme.surface : AppTheme.surface.opacity(0.5))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .disabled(contactsStatus != .authorized)
                                    .buttonStyle(.plain)

                                    Button {
                                        presentDeviceContactsForSelection()
                                    } label: {
                                        Text("Import from device")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity, minHeight: 44)
                                            .background(contactsStatus == .authorized ? AppTheme.surface : AppTheme.surface.opacity(0.5))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .disabled(contactsStatus != .authorized)
                                    .buttonStyle(.plain)

                                    if isImportingAll {
                                        Text("Importing contacts…")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }

                                    if contactsStatus != .authorized {
                                        Text("Grant Contacts permission to import.")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .padding(.top, 2)
                                    }
                                }
                            } else {
                                Text("Contacts imported")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .padding(.top, 6)
                            }
                        }
                        .onAppear {
                            if contactsStatus == .authorized && !state.hasImportedDeviceContacts {
                                isImportingAll = true
                                fetchDeviceContacts { contacts in
                                    var importedItems: [ContactItem] = []
                                    for c in contacts {
                                        let name = displayName(for: c)
                                        let phone = c.phoneNumbers.first?.value.stringValue
                                        let email = c.emailAddresses.first.map { String($0.value) }
                                        let photo = c.imageDataAvailable ? c.thumbnailImageData : nil
                                        let candidate = ContactItem(name: name, relation: nil, phone: phone, email: email, photoData: photo, audioNoteURL: nil)
                                        if state.canAddContact(name: candidate.name, relation: candidate.relation) {
                                            importedItems.append(candidate)
                                        }
                                    }
                                    if !importedItems.isEmpty {
                                        state.contacts.append(contentsOf: importedItems)
                                        state.saveContacts()
                                    }
                                    state.setContactsImported()
                                    isImportingAll = false
                                }
                            }
                        }
                        .onChange(of: contactsStatus) { newStatus in
                            if newStatus == .authorized && !state.hasImportedDeviceContacts {
                                isImportingAll = true
                                fetchDeviceContacts { contacts in
                                    var importedItems: [ContactItem] = []
                                    for c in contacts {
                                        let name = displayName(for: c)
                                        let phone = c.phoneNumbers.first?.value.stringValue
                                        let email = c.emailAddresses.first.map { String($0.value) }
                                        let photo = c.imageDataAvailable ? c.thumbnailImageData : nil
                                        let candidate = ContactItem(name: name, relation: nil, phone: phone, email: email, photoData: photo, audioNoteURL: nil)
                                        if state.canAddContact(name: candidate.name, relation: candidate.relation) {
                                            importedItems.append(candidate)
                                        }
                                    }
                                    if !importedItems.isEmpty {
                                        state.contacts.append(contentsOf: importedItems)
                                        state.saveContacts()
                                    }
                                    state.setContactsImported()
                                    isImportingAll = false
                                }
                            }
                        }
                        .frame(width: width)

                        // Page 2 - Microphone
                        Screen {
                            permissionCard(
                                title: "Microphone",
                                icon: "mic.fill",
                                statusText: micStatusText,
                                isGranted: micStatus == .granted,
                                requestAction: requestMic
                            )
                        }
                        .frame(width: width)

                        // Page 3 - Camera
                        Screen {
                            permissionCard(
                                title: "Camera",
                                icon: "camera.fill",
                                statusText: cameraStatusText,
                                isGranted: cameraStatus == .authorized,
                                requestAction: requestCamera
                            )
                        }
                        .frame(width: width)

                        // Page 4 - Notifications
                        Screen {
                            permissionCard(
                                title: "Notifications",
                                icon: "bell.badge.fill",
                                statusText: notificationsStatusText,
                                isGranted: notificationsStatus == .authorized,
                                requestAction: requestNotifications
                            )
                        }
                        .frame(width: width)

                        // Page 5 - Medical Report
                        Screen {
                            CardDark {
                                HStack(spacing: 10) {
                                    Image(systemName: "doc.richtext.fill").foregroundStyle(iconColor)
                                    Text("Medical Report")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(iconColor)
                                    Spacer()
                                    Text(medicalReportImportStatus)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(medicalReportImportStatus == "Imported" ? AppTheme.success : textSecondary)
                                }
                                Button {
                                    isPresentingMedicalDocPicker = true
                                } label: {
                                    Text("Import medical report")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(AppTheme.primary)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                if !medicalReportTextPreview.isEmpty {
                                    Text(medicalReportTextPreview)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(4)
                                }

                                Button {
                                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                                        currentPage = min(currentPage + 1, 6)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text("Continue")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(AppTheme.primary)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(width: width)

                        // Page 6 - Continue
                        Screen {
                            Button {
                                state.setOnboardingCompleted()
                            } label: {
                                Text("Continue")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .background(AppTheme.primary)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 6)
                        }
                        .frame(width: width)
                    }
                    .offset(x: -CGFloat(currentPage) * width + dragOffset)
                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2), value: currentPage)
                    .gesture(
                        DragGesture(minimumDistance: 25, coordinateSpace: .local)
                            .onChanged { value in
                                let translation = value.translation
                                // Only consider mostly-horizontal drags
                                guard abs(translation.width) > abs(translation.height) else { return }

                                // Apply resistance when at the edges to avoid excessive overscroll
                                let width = geo.size.width
                                let proposed = translation.width
                                let isAtFirst = currentPage == 0 && proposed > 0
                                let isAtLast = currentPage == 6 && proposed < 0
                                if isAtFirst || isAtLast {
                                    dragOffset = proposed * 0.3
                                } else {
                                    dragOffset = proposed
                                }
                            }
                            .onEnded { value in
                                let translationX = value.translation.width
                                let velocityX = value.velocity?.width ?? 0 // optional on older SDKs, guarded below

                                // Sensitivity tuning: require a fairly long, steady swipe to reduce errors
                                let distanceThreshold: CGFloat = 120
                                let velocityThreshold: CGFloat = 250 // keep it relatively low-velocity to avoid accidental flicks

                                var nextPage = currentPage
                                if translationX < -distanceThreshold || velocityX < -velocityThreshold {
                                    nextPage = min(currentPage + 1, 6)
                                } else if translationX > distanceThreshold || velocityX > velocityThreshold {
                                    nextPage = max(currentPage - 1, 0)
                                }

                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                                    currentPage = nextPage
                                    dragOffset = 0
                                }
                            },
                        including: (isPresentingContactPicker || isImportingAll || isImportingSelection) ? .subviews : .all
                    )
                    .disabled(isPresentingContactPicker || isImportingAll || isImportingSelection)
                    .sheet(isPresented: $isPresentingContactPicker) {
                        NavigationStack {
                            List {
                                ForEach(deviceContacts, id: \.identifier) { (contact: CNContact) in
                                    let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "Unnamed"
                                    HStack {
                                        Text(name)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Spacer()
                                        if selectedContactIdentifiers.contains(contact.identifier) {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.primary)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        toggleSelection(for: contact)
                                    }
                                }
                            }
                            .navigationTitle("Select Contacts")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { isPresentingContactPicker = false }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Import") { importSelectedContacts() }
                                        .disabled(selectedContactIdentifiers.isEmpty)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $isPresentingMedicalDocPicker) {
                        DocumentPickerView { result in
                            handleMedicalReportImport(result: result)
                        }
                    }

                    VStack(spacing: 10) {
                        // Dynamic title centered
                        Text(pageTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(pageTitle)

                        // Step indicator and subtitle
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step \(currentPage + 1) of 7")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(textSecondary)
                                .accessibilityLabel("Step \(currentPage + 1) of 7")

                            Text(currentPage == 0 ? "You're at the first step: configure permissions to get started." : "Continue configuring permissions.")
                                .font(.caption2)
                                .foregroundStyle(textSecondary)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Page dots
                        HStack(spacing: 6) {
                            ForEach(0..<7, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage
                                        ? AppTheme.primary
                                        : AppTheme.primary.opacity(0.35))
                                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }

                        // Back / Next controls
                        HStack {
                            Button {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                                    currentPage = max(currentPage - 1, 0)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 40)
                                .background(AppTheme.surface)
                                .foregroundStyle(AppTheme.textPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(AppTheme.textSecondary.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                            .opacity(currentPage == 0 ? 0.5 : 1.0)
                            .disabled(currentPage == 0)

                            Spacer()

                            Button {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                                    if currentPage == 6 {
                                        state.setOnboardingCompleted()
                                    } else {
                                        currentPage = min(currentPage + 1, 6)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(currentPage == 6 ? "Done" : "Next")
                                    Image(systemName: currentPage == 6 ? "checkmark" : "chevron.right")
                                }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .frame(minHeight: 40)
                                .background(AppTheme.primary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Skip / Manage row
                        HStack(spacing: 12) {
                            Button {
                                // Skip onboarding for now
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                state.setOnboardingCompleted()
                            } label: {
                                Text("Skip for now")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .background(AppTheme.surface)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "gearshape.fill")
                                    Text("Manage permissions")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(minHeight: 36)
                                .padding(.horizontal, 14)
                                .background(AppTheme.primary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Permissions")
        }
        .onAppear { refreshStatuses() }
    }

    // MARK: - Cards
    private func permissionCard(title: String, icon: String, statusText: String, isGranted: Bool, requestAction: @escaping () -> Void) -> some View {
        CardDark {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(iconColor)
                Spacer()
                Text(statusText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isGranted ? AppTheme.success : textSecondary)
            }
            Button(action: requestAction) {
                Text(isGranted ? "Granted" : "Allow")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isGranted ? AppTheme.success : AppTheme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(isGranted)
            .buttonStyle(.plain)

            Button {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.85)) {
                    currentPage = min(currentPage + 1, 6)
                }
            } label: {
                HStack(spacing: 6) {
                    Text("Continue")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(AppTheme.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Status texts
    private var contactStatusText: String {
        switch contactsStatus {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not determined"
        @unknown default: return "Unknown"
        }
    }

    private var micStatusText: String {
        switch micStatus {
        case .granted: return "Authorized"
        case .denied: return "Denied"
        case .undetermined: return "Not determined"
        @unknown default: return "Unknown"
        }
    }

    private var cameraStatusText: String {
        switch cameraStatus {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not determined"
        @unknown default: return "Unknown"
        }
    }

    private var notificationsStatusText: String {
        switch notificationsStatus {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .ephemeral: return "Ephemeral"
        case .notDetermined: return "Not determined"
        case .provisional: return "Provisional"
        @unknown default: return "Unknown"
        }
    }

    // MARK: - Requests
    private func requestContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { _, _ in
            DispatchQueue.main.async { refreshStatuses() }
        }
    }

    private func requestMic() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async { refreshStatuses() }
        }
    }

    private func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            DispatchQueue.main.async { refreshStatuses() }
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.notificationsStatus = settings.authorizationStatus
                }
            }
        }
    }

    private func refreshStatuses() {
        contactsStatus = CNContactStore.authorizationStatus(for: .contacts)
        micStatus = AVAudioSession.sharedInstance().recordPermission
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsStatus = settings.authorizationStatus
            }
        }
    }

    // MARK: - Contacts Import
    private func importAllContacts() {
        guard contactsStatus == .authorized else { return }
        isImportingAll = true
        fetchDeviceContacts { contacts in
            var importedItems: [ContactItem] = []
            for c in contacts {
                let name = displayName(for: c)
                let phone = c.phoneNumbers.first?.value.stringValue
                let email = c.emailAddresses.first.map { String($0.value) }
                let photo = c.imageDataAvailable ? c.thumbnailImageData : nil
                let candidate = ContactItem(name: name, relation: nil, phone: phone, email: email, photoData: photo, audioNoteURL: nil)
                if state.canAddContact(name: candidate.name, relation: candidate.relation) {
                    importedItems.append(candidate)
                }
            }
            if !importedItems.isEmpty {
                state.contacts.append(contentsOf: importedItems)
                state.saveContacts()
            }
            state.setContactsImported()
            isImportingAll = false
        }
    }

    private func presentDeviceContactsForSelection() {
        guard contactsStatus == .authorized else { return }
        fetchDeviceContacts { contacts in
            self.deviceContacts = contacts
            self.selectedContactIdentifiers.removeAll()
            self.isPresentingContactPicker = true
        }
    }

    private func toggleSelection(for contact: CNContact) {
        if selectedContactIdentifiers.contains(contact.identifier) {
            selectedContactIdentifiers.remove(contact.identifier)
        } else {
            selectedContactIdentifiers.insert(contact.identifier)
        }
    }

    private func importSelectedContacts() {
        guard contactsStatus == .authorized else { return }
        let selected = deviceContacts.filter { selectedContactIdentifiers.contains($0.identifier) }
        isImportingSelection = true
        var importedItems: [ContactItem] = []
        for c in selected {
            let name = displayName(for: c)
            let phone = c.phoneNumbers.first?.value.stringValue
            let email = c.emailAddresses.first.map { String($0.value) }
            let photo = c.imageDataAvailable ? c.thumbnailImageData : nil
            let candidate = ContactItem(name: name, relation: nil, phone: phone, email: email, photoData: photo, audioNoteURL: nil)
            if state.canAddContact(name: candidate.name, relation: candidate.relation) {
                importedItems.append(candidate)
            }
        }
        if !importedItems.isEmpty {
            state.contacts.append(contentsOf: importedItems)
            state.saveContacts()
        }
        state.setContactsImported()
        isImportingSelection = false
        isPresentingContactPicker = false
    }

    private func fetchDeviceContacts(completion: @escaping ([CNContact]) -> Void) {
        guard contactsStatus == .authorized else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        ]
        var all = [CNContact]()
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        request.sortOrder = .userDefault
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    all.append(contact)
                }
                DispatchQueue.main.async { completion(all) }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    // MARK: - Medical Report Import
    private func handleMedicalReportImport(result: Result<String, Error>) {
        switch result {
        case .success(let text):
            // Store a small preview
            self.medicalReportTextPreview = String(text.prefix(300)) + (text.count > 300 ? "…" : "")
            // Parse and apply to app state (stub)
            applyMedicalReportText(text)
            self.medicalReportImportStatus = "Imported"
        case .failure:
            self.medicalReportImportStatus = "Failed"
        }
    }

    private func applyMedicalReportText(_ text: String) {
        // TODO: Replace with real parsing. Below is a simple placeholder extractor.
        // Example: look for lines starting with keywords like "Medication:" or "Task:".
        var medications: [String] = []
        var tasks: [String] = []
        let lines = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        for line in lines {
            if line.lowercased().hasPrefix("medication:") || line.lowercased().hasPrefix("farmaco:") {
                let item = line.split(separator: ":", maxSplits: 1).last.map(String.init) ?? ""
                if !item.isEmpty { medications.append(item.trimmingCharacters(in: .whitespaces)) }
            } else if line.lowercased().hasPrefix("task:") || line.lowercased().hasPrefix("attivita:") || line.lowercased().hasPrefix("azione:") {
                let item = line.split(separator: ":", maxSplits: 1).last.map(String.init) ?? ""
                if !item.isEmpty { tasks.append(item.trimmingCharacters(in: .whitespaces)) }
            }
        }
        // Hook into your app's logic. If AppState has dedicated APIs, call them here.
        // The following is a placeholder you can implement inside AppState:
        // state.applyMedicalReport(medications: medications, tasks: tasks)
    }
}

private extension DragGesture.Value {
    var velocity: CGSize? {
        #if compiler(>=6.0)
        // Approximate using predicted end translation if available in this SDK
        return CGSize(width: predictedEndTranslation.width - translation.width,
                      height: predictedEndTranslation.height - translation.height)
        #else
        return nil
        #endif
    }
}

// MARK: - Document Picker Wrapper
private struct DocumentPickerView: View {
    var onComplete: (Result<String, Error>) -> Void
    var body: some View {
        DocumentPickerRepresentable(onComplete: onComplete)
            .ignoresSafeArea()
    }
}

private struct DocumentPickerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDocumentPickerViewController

    var onComplete: (Result<String, Error>) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.pdf, .plainText, .rtf, .utf8PlainText]
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onComplete: (Result<String, Error>) -> Void
        init(onComplete: @escaping (Result<String, Error>) -> Void) { self.onComplete = onComplete }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Attempt to read text from supported types
            do {
                var text = ""
                if url.pathExtension.lowercased() == "pdf" {
                    text = try extractTextFromPDF(url: url)
                } else {
                    text = try String(contentsOf: url, encoding: .utf8)
                }
                onComplete(.success(text))
            } catch {
                onComplete(.failure(error))
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onComplete(.failure(NSError(domain: "DocumentPicker", code: 1)))
        }

        private func extractTextFromPDF(url: URL) throws -> String {
#if canImport(PDFKit)
            guard let pdf = PDFDocument(url: url) else { throw NSError(domain: "PDF", code: 0) }
            var all = ""
            for i in 0..<(pdf.pageCount) {
                if let page = pdf.page(at: i), let s = page.string { all += s + "\n" }
            }
            return all
#else
            throw NSError(domain: "PDF", code: -1, userInfo: [NSLocalizedDescriptionKey: "PDFKit not available on this platform."])
#endif
        }
    }
}

