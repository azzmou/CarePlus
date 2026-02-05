//
//  AddCallView.swift
//  Care+
//
//  Manual call log helper (optional debug)
//

import SwiftUI

struct AddCallView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedContactId: UUID?
    @State private var date: Date = .now

    private var canSave: Bool {
        selectedContactId != nil
    }

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    Text("Add call log")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    DatePicker("Date", selection: $date)
                        .foregroundStyle(.white)

                    Picker("Contact", selection: $selectedContactId) {
                        Text("Select…").tag(UUID?.none)
                        ForEach(state.contacts) { c in
                            Text(label(for: c)).tag(UUID?.some(c.id))
                        }
                    }
                    .pickerStyle(.menu)

                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        guard let id = selectedContactId,
                              let c = state.contacts.first(where: { $0.id == id })
                        else { return }

                        state.callEvents.insert(
                            CallEvent(contactKey: c.uniqueKey, timestamp: date),
                            at: 0
                        )
                        state.saveCalls()
                        dismiss()
                    } label: {
                        Text("SAVE")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .opacity(canSave ? 1 : 0.45)
                    }
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Add call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func label(for c: ContactItem) -> String {
        if let r = c.relation, !r.isEmpty { return "\(c.name) (\(r))" }
        return c.name
    }
}
