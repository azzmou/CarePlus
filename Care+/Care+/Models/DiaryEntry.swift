//
//  DiaryEntry.swift
//  Care+
//
//  Diary entry model
//

import Foundation

enum Mood: String, Codable, Hashable {
    case notGood
    case okay
    case perfect

    var emoji: String {
        switch self {
        case .notGood: return "😕"
        case .okay: return "🙂"
        case .perfect: return "😍"
        }
    }
}

struct DiaryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var text: String
    var imageData: Data?
    var videoURL: URL?
    var audioURL: URL?
    var mood: Mood?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date = .now,
        text: String,
        imageData: Data? = nil,
        videoURL: URL? = nil,
        audioURL: URL? = nil,
        mood: Mood? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.imageData = imageData
        self.videoURL = videoURL
        self.audioURL = audioURL
        self.mood = mood
        let created = createdAt ?? date
        self.createdAt = created
        self.updatedAt = updatedAt ?? created
    }
}
