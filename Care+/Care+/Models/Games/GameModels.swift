//
//  GameModels.swift
//  Care+
//

import Foundation

enum GameType: String, Codable, CaseIterable {
    case guessWho
}

struct GuessWhoRoundResult: Codable, Hashable {
    var roundIndex: Int
    var contactKey: String
    var isCorrect: Bool
    var attempts: Int
}

struct GameSessionResult: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var type: GameType
    var startedAt: Date
    var finishedAt: Date
    var durationSeconds: Int
    var totalRounds: Int
    var correctCount: Int
    var totalAttempts: Int
    var roundResults: [GuessWhoRoundResult]
}
