//
//  Card.swift
//  Care+
//

import SwiftUI

struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme

    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .background(
            shape
                .fill(scheme == .dark ? AppTheme.containerDark : AppTheme.containerLight)
                // leggero “lift” in dark per look più simile allo screen (non cambia in light)
                .overlay(
                    shape.fill(
                        scheme == .dark
                        ? AppTheme.secondary.opacity(0.06)
                        : Color.clear
                    )
                )
        )
        .clipShape(shape)
        .overlay(
            shape.stroke(
                scheme == .dark
                ? AppTheme.secondary.opacity(0.12)          // bordo soft teal (no bianco “glass”)
                : AppTheme.iconLight.opacity(0.12),
                lineWidth: 1
            )
        )
        .shadow(
            color: scheme == .dark ? .black.opacity(0.18) : .black.opacity(0.08),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}
