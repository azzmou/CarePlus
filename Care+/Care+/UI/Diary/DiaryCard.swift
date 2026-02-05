//
//  DiaryCard.swift
//  Care+
//

import SwiftUI
import AVKit

struct DiaryCard: View {
    let entry: DiaryEntry
    let onPlayAudio: () -> Void

    var body: some View {
        CardDark {
            VStack(alignment: .leading, spacing: 10) {
                Text(entry.date.formatted(.dateTime.day().month().year().hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                if !entry.text.isEmpty {
                    Text(entry.text)
                        .foregroundStyle(.white)
                }

                if let data = entry.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                if let url = entry.videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                HStack(spacing: 10) {
                    if entry.imageData != nil { MiniChip(icon: "photo", text: "Photo") }
                    if entry.videoURL != nil { MiniChip(icon: "video", text: "Video") }
                    if entry.audioURL != nil { MiniChip(icon: "waveform", text: "Audio") }
                    Spacer()
                    if entry.audioURL != nil {
                        Button(action: onPlayAudio) {
                            Image(systemName: "play.fill")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Circle())
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
