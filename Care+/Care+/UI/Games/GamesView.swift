//
//  GamesView.swift
//  Care+
//

import SwiftUI
import UIKit

struct GamesView: View {
    @Bindable var state: AppState
    @Environment(\.colorScheme) private var scheme

    private var textPrimary: Color { scheme == .dark ? .white : AppTheme.iconLight }
    private var textSecondary: Color { scheme == .dark ? .white.opacity(0.75) : AppTheme.iconLight.opacity(0.70) }
    private var iconColor: Color { scheme == .dark ? .white : AppTheme.iconLight }

    var body: some View {
        NavigationStack {
            Screen {
                // Today's activities card
                CardDark {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "puzzlepiece.fill")
                                .font(.headline)
                                .foregroundStyle(iconColor)
                            Text("Today's activities")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(iconColor)
                            Spacer()
                        }

                        let gamesDoneToday = min(3, state.gameSessions(on: .now).count)
                        Text(gamesDoneToday == 0
                             ? "You completed 0/3 memory games"
                             : "Great! You completed \(gamesDoneToday)/3 memory games")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(textPrimary)

                        ProgressView(value: Double(gamesDoneToday), total: 3.0)
                            .tint(Color.white.opacity(0.9))

                        Button {
                            // Placeholder for objectives
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text("Objectives")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.white.opacity(0.92))
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                }

                // Games grid card
                CardDark {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.headline)
                                .foregroundStyle(iconColor)
                            Text("Games")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(iconColor)
                            Spacer()
                        }

                        Text("Train your memory")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(textPrimary)

                        // 2x2 grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            // Memory (active)
                            NavigationLink {
                                GuessWhoGameView(state: state)
                            } label: {
                                gameTileImage(title: "Memory", imageCandidates: ["game_memory", "Memory", "memory"])
                            }
                            .buttonStyle(.plain)

                            // Attention (coming soon)
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                gameTileImage(title: "Attention", imageCandidates: ["game_attention", "Attention", "attention"]).overlay(comingSoonOverlay)
                            }
                            .buttonStyle(.plain)
                            .disabled(true)

                            // Logic (coming soon)
                            Button {} label: {
                                gameTileImage(title: "Logic", imageCandidates: ["game_logic", "Logic", "logic"]).overlay(comingSoonOverlay)
                            }
                            .buttonStyle(.plain)
                            .disabled(true)

                            // What Difference? (coming soon)
                            Button {} label: {
                                gameTileImage(title: "What Difference?", imageCandidates: ["game_difference", "what_difference", "WhatDifference", "What Difference"]).overlay(comingSoonOverlay)
                            }
                            .buttonStyle(.plain)
                            .disabled(true)
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var comingSoonOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
            Text("Coming soon")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(6)
                .background(Color.black.opacity(0.4))
                .clipShape(Capsule())
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func fallbackEmoji(for title: String) -> String {
        switch title {
        case "Memory": return "🧠"
        case "Attention": return "🔍"
        case "Logic": return "🧩"
        case "What Difference?": return "⚽️"
        default: return "🎮"
        }
    }

    private func gameTileImage(title: String, imageCandidates: [String]) -> some View {
        let ui: UIImage? = imageCandidates.compactMap { UIImage(named: $0) }.first
        return Group {
            if let ui {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                gameTile(title: title, emoji: fallbackEmoji(for: title), accent: .white)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func gameTile(title: String, emoji: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(emoji)
                .font(.largeTitle)
            Spacer()
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

