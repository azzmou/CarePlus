//
//  AudioPlayer.swift
//  Care+
//

import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioPlayer: NSObject, ObservableObject {
    @Published var isPlaying = false
    private var player: AVAudioPlayer?
    var onFinish: (() -> Void)?

    override init() {}

    func play(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
            try session.setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()

            player = p
            isPlaying = true
            // Clear any previous finish callback state if needed (no-op)
        } catch {
            isPlaying = false
            player = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        self.player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        onFinish?()
    }
}

