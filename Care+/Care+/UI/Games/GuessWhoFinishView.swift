//
//  GuessWhoFinishView.swift
//  Care+
//

import SwiftUI

struct GuessWhoFinishView: View {
    @Bindable var state: AppState

    let durationSeconds: Int
    let correctCount: Int
    let totalRounds: Int
    let totalAttempts: Int
    let roundResults: [GuessWhoRoundResult]

    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    Text("Finished 🎉")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Score: \(correctCount)/\(totalRounds)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Time: \(durationSeconds)s")
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Attempts: \(totalAttempts)")
                        .foregroundStyle(.white.opacity(0.8))

                    let avg = totalRounds > 0 ? Double(totalAttempts) / Double(totalRounds) : 0
                    Text(String(format: "Avg attempts/round: %.2f", avg))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                CardDark {
                    Text("Rounds")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    ForEach(roundResults, id: \.roundIndex) { r in
                        HStack {
                            Text("Round \(r.roundIndex + 1)")
                                .foregroundStyle(.white)
                            Spacer()
                            Text(r.isCorrect ? "✅" : "❌")
                            Text("tries: \(r.attempts)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        onRetry()
                    } label: {
                        Text("RETRY")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Button {
                        onClose()
                    } label: {
                        Text("CLOSE")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color.white.opacity(0.18))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                    }
                }
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
