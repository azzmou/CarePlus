//
//  GamesStatsView.swift
//  Care+
//

import SwiftUI
import Charts

struct GamesStatsView: View {
    @Bindable var state: AppState
    @State private var selectedDay: Date = .now

    private var daySessions: [GameSessionResult] {
        state.gameSessions(on: selectedDay, type: .guessWho)
    }

    private var monthlyAgg: (sessions: Int, totalAttempts: Int, avgTimeSec: Double, avgScore: Double) {
        state.gameMonthlyAggregateLastNDays(days: 30, now: .now, type: .guessWho)
    }

    private var scoreChart: [(dayStart: Date, avgScore: Double, sessions: Int)] {
        state.guessWhoAvgScorePerDayLastNDays(days: 14, now: .now)
    }

    private var attemptsChart: [(dayStart: Date, attempts: Int)] {
        state.guessWhoAttemptsPerDayLastNDays(days: 14, now: .now)
    }

    var body: some View {
        VStack(spacing: 16) {

            CardDark {
                Text("Guess Who — Daily sessions")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                DatePicker("Day", selection: $selectedDay, displayedComponents: .date)
                    .foregroundStyle(.white)

                if daySessions.isEmpty {
                    Text("No sessions on this day.")
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    ForEach(daySessions) { s in
                        let scoreText = "\(s.correctCount)/\(s.totalRounds)"
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(s.finishedAt.formatted(.dateTime.hour().minute()))
                                    .foregroundStyle(.white)
                                    .font(.headline)

                                Text("Time: \(s.durationSeconds)s • Attempts: \(s.totalAttempts)")
                                    .foregroundStyle(.white.opacity(0.7))
                                    .font(.caption)
                            }
                            Spacer()
                            Text(scoreText)
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            CardDark {
                Text("Monthly overview (last 30 days)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sessions: \(monthlyAgg.sessions)")
                            .foregroundStyle(.white)
                        Text("Total attempts: \(monthlyAgg.totalAttempts)")
                            .foregroundStyle(.white.opacity(0.85))
                            .font(.caption)
                    }
                    Spacer()
                }

                HStack {
                    Text(String(format: "Avg time: %.0fs", monthlyAgg.avgTimeSec))
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                    Text(String(format: "Avg score: %.0f%%", monthlyAgg.avgScore * 100))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .font(.caption)
            }

            CardDark {
                Text("Avg score trend (last 14 days)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Chart(scoreChart, id: \.dayStart) { p in
                    LineMark(
                        x: .value("Day", p.dayStart, unit: .day),
                        y: .value("AvgScore", p.avgScore)
                    )
                    PointMark(
                        x: .value("Day", p.dayStart, unit: .day),
                        y: .value("AvgScore", p.avgScore)
                    )
                }
                .chartYScale(domain: 0...1)
                .frame(height: 180)

                Text("0–100% average score per day.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            CardDark {
                Text("Attempts trend (last 14 days)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Chart(attemptsChart, id: \.dayStart) { p in
                    BarMark(
                        x: .value("Day", p.dayStart, unit: .day),
                        y: .value("Attempts", p.attempts)
                    )
                }
                .frame(height: 180)

                Text("Total attempts per day (all sessions).")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
