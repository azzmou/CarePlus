//
//  MiniChip.swift
//  Care+
//

import SwiftUI

struct MiniChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption)
            Text(text).font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.10), Color.white.opacity(0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            LinearGradient(
                colors: [Color.white.opacity(0.18), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
        )
        .foregroundStyle(.white.opacity(0.9))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 4)
    }
}
