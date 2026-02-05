//
//  Persistence.swift
//  Care+
//
//  Simple JSON persistence (UserDefaults)
//

import Foundation

enum Persistence {
    static func load<T: Decodable>(_ type: T.Type, key: String, defaultValue: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
        return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
    }

    static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func scopedKey(key: String, userId: String) -> String {
        return "\(key)__\(userId)"
    }

    static func save<T: Encodable>(_ value: T, key: String, userId: String) {
        let sk = scopedKey(key: key, userId: userId)
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: sk)
    }

    static func load<T: Decodable>(_ type: T.Type, key: String, userId: String, defaultValue: T) -> T {
        let sk = scopedKey(key: key, userId: userId)
        guard let data = UserDefaults.standard.data(forKey: sk) else { return defaultValue }
        return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
    }
}
