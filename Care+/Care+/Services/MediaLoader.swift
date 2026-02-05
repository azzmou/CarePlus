//
//  MediaLoader.swift
//  Care+
//
//  PhotosPicker media loader (image or video)
//

import Foundation
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct MediaLoader {
    struct Result {
        let imageData: Data?
        let videoURL: URL?
    }

    private struct Movie: Transferable {
        let url: URL

        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(importedContentType: .movie) { received in
                Self(url: received.file)
            }
        }
    }

    /// Loads media from a PhotosPickerItem asynchronously.
    /// - Returns: image data OR video url (best effort).
    static func load(from item: PhotosPickerItem?) async -> Result {
        guard let item else {
            return Result(imageData: nil, videoURL: nil)
        }

        // Try image first
        if let imageData = try? await item.loadTransferable(type: Data.self) {
            return Result(imageData: imageData, videoURL: nil)
        }

        // Determine content type (best-effort, iOS16+)
        let preferredContentType: UTType? = {
            if #available(iOS 16, *) {
                return item.supportedContentTypes.first
            } else {
                return nil
            }
        }()

        func isMovieType(_ type: UTType) -> Bool {
            type.conforms(to: .movie)
        }

        // Try direct URL
        if let videoURL = try? await item.loadTransferable(type: URL.self) {
            return Result(imageData: nil, videoURL: videoURL)
        }

        // Try custom transferable movie
        if let movie = try? await item.loadTransferable(type: Movie.self) {
            return Result(imageData: nil, videoURL: movie.url)
        }

        // Fallback: raw Data -> temp .mov
        if let contentType = preferredContentType, isMovieType(contentType) {
            if let videoData = try? await item.loadTransferable(type: Data.self) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mov")
                do {
                    try videoData.write(to: tempURL, options: .atomic)
                    return Result(imageData: nil, videoURL: tempURL)
                } catch {
                    // fall through
                }
            }
        }

        return Result(imageData: nil, videoURL: nil)
    }
}
