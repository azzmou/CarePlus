//
//  ContactsView.swift
//  Care+
//

import SwiftUI

struct ContactsListView: View {
    @Bindable var state: AppState

    @State private var showAdd = false
    @State private var search = ""
    @State private var showDeleteAlert = false
    @State private var pendingDeleteContactID: UUID? = nil

    @Environment(\.colorScheme) private var scheme
    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    private var searchFill: Color { scheme == .dark ? Color.white.opacity(0.10) : AppTheme.iconLight.opacity(0.10) }
    private var searchStroke: Color { scheme == .dark ? Color.white.opacity(0.12) : AppTheme.iconLight.opacity(0.16) }

    private var filtered: [ContactItem] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return state.contacts }
        return state.contacts.filter {
            $0.name.lowercased().contains(q)
            || ($0.relation?.lowercased().contains(q) ?? false)
            || ($0.phone?.lowercased().contains(q) ?? false)
            || ($0.email?.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            Screen {
                // ✅ Header identico a Tasks/Diary (titolo centrato, stesso colore)
                header

                // Search
                CardDark {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(textSecondary)

                        TextField("Search contacts…", text: $search)
                            .foregroundStyle(textPrimary)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(searchFill)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(searchStroke, lineWidth: 1)
                    )
                }

                // Actions / Info
                CardDark {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Address Book")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(scheme == .dark ? .white : .black)

                        if state.contacts.isEmpty {
                            Button { importDeviceContacts() } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Import from Contacts")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(scheme == .dark ? Color.white.opacity(0.92) : AppTheme.iconLight.opacity(0.15))
                                .foregroundStyle(scheme == .dark ? .black : textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }

                        NavigationLink {
                            DialPadView(state: state)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.grid.3x3.fill")
                                Text("Dial pad")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(scheme == .dark ? Color.white.opacity(0.92) : AppTheme.iconLight.opacity(0.15))
                            .foregroundStyle(scheme == .dark ? .black : textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        if state.contacts.isEmpty {
                            Text("You can import your address book; then optionally add photos and audios.")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }

                // Contacts list (keeps Apple list styling)
                List {
                    ForEach(filtered) { contact in
                        NavigationLink {
                            ContactDetailView(state: state, contact: binding(for: contact))
                        } label: {
                            HStack(spacing: 12) {
                                Avatar(photo: contact.photoData)
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contact.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(contact.relation?.isEmpty == false ? contact.relation! : (contact.phone ?? ""))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 8)

                                Button(role: .destructive) {
                                    pendingDeleteContactID = contact.id
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(AppTheme.danger)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indices in
                        let toDelete = indices.map { filtered[$0] }
                        for item in toDelete {
                            if let idx = state.contacts.firstIndex(where: { $0.id == item.id }) {
                                state.contacts.remove(at: idx)
                            }
                        }
                        state.saveContacts()
                    }
                }
                .listStyle(.insetGrouped)
                .alert("Eliminare questo contatto?", isPresented: $showDeleteAlert) {
                    Button("Elimina", role: .destructive) {
                        if let id = pendingDeleteContactID,
                           let idx = state.contacts.firstIndex(where: { $0.id == id }) {
                            state.contacts.remove(at: idx)
                            state.saveContacts()
                        }
                        pendingDeleteContactID = nil
                    }
                    Button("Annulla", role: .cancel) {
                        pendingDeleteContactID = nil
                    }
                } message: {
                    Text("Questa azione non può essere annullata.")
                }

                // ✅ Bottom Add button (kept as you had, but themed)
                HStack {
                    Spacer()
                    Button { showAdd = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("Add").font(.headline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(scheme == .dark ? Color.white.opacity(0.92) : AppTheme.iconLight.opacity(0.15))
                        .foregroundStyle(scheme == .dark ? .black : textPrimary)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(scheme == .dark ? 0.22 : 0.12), radius: 12, x: 0, y: 8)
                    }
                }
                .padding(.top, 6)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar) // ✅ like Tasks/Diary
            .sheet(isPresented: $showAdd) {
                AddContactView(state: state) { newItem in
                    state.contacts.append(newItem)
                    state.saveContacts()
                }
            }
        }
    }

    // MARK: - Header (same pattern as Tasks/Diary)
    private var header: some View {
        HStack {
            Color.clear.frame(width: 44, height: 44)

            Spacer()

            Text("Contacts")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(red: 56/255, green: 120/255, blue: 118/255))

            Spacer()

            // Right action: open add contact
            Button {
                showAdd = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add contact")
        }
        .padding(.top, 2)
        .padding(.bottom, 6)
    }

    private func binding(for contact: ContactItem) -> Binding<ContactItem> {
        guard let index = state.contacts.firstIndex(where: { $0.id == contact.id }) else {
            return .constant(contact)
        }
        return $state.contacts[index]
    }

    private func importDeviceContacts() {
        ContactsImportService.importFromDevice(existing: state.contacts) { imported in
            guard !imported.isEmpty else { return }
            state.contacts.append(contentsOf: imported)
            state.saveContacts()
        }
    }
}

