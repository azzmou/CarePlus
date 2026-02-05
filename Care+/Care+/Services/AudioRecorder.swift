//
//  AudioRecorder.swift
//  Care+
//

import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var lastRecordingURL: URL?

    private var recorder: AVAudioRecorder?

    init() {}

    func start() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)

            let url = FileStore.tempURL(ext: "m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let rec = try AVAudioRecorder(url: url, settings: settings)
            rec.record()

            recorder = rec
            isRecording = true
            lastRecordingURL = nil
        } catch {
            isRecording = false
            recorder = nil
        }
    }

    func stop() {
        recorder?.stop()
        lastRecordingURL = recorder?.url
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

