//
//  FileStore.swift
//  Care+
//
//  Temporary file helpers
//

import Foundation

enum FileStore {

    static func tempURL(ext: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
    }

    static func writeTemp(data: Data, ext: String) -> URL? {
        let url = tempURL(ext: ext)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
