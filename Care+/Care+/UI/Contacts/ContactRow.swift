//
//  ContactRow.swift
//  Care+
//

import SwiftUI

struct ContactRow: View {
    @Bindable var state: AppState
    let contact: ContactItem

    var body: some View {
        CardDark {
            HStack(spacing: 12) {
                Avatar(photo: contact.photoData)

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    if let rel = contact.relation, !rel.isEmpty {
                        Text(rel)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if let phone = contact.phone, !phone.isEmpty {
                        Text(phone).font(.caption).foregroundStyle(.white.opacity(0.7))
                    } else if let email = contact.email, !email.isEmpty {
                        Text(email).font(.caption).foregroundStyle(.white.opacity(0.7))
                    }

                    // Small call stats (optional but helpful)
                    let sum = state.callSummary(for: contact, on: .now)
                    if sum.count > 0 {
                        Text("Today: \(sum.count) • Last: \(sum.last?.formatted(.dateTime.hour().minute()) ?? "—")")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                            .padding(.top, 2)
                    }
                }

                Spacer()

                if contact.phone != nil {
                    Button {
                        CallHelper.call(contact: contact, state: state)
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.headline)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

