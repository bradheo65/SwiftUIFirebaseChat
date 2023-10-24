//
//  AudioRecorderViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/04.
//

import Foundation
import AVFoundation

final class AudioRecorderViewModel: NSObject, ObservableObject {
        
    // 음성메모 녹음
    private var audioRecorder: AVAudioRecorder = AVAudioRecorder()
    @Published var isRecording = false
    var recordedFiles = [URL]()
    
    // 음성메모 재생
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var isEndPlay = false
    
    private let chatUser: ChatUser?

    private let sendFileMessageUseCase: SendFileMessageUseCaseProtocol
    
    private var timer: Timer?
    
    private var currentSample: Int = 0
    private let numberOfSamples: Int = 20
    
    @Published var soundSamples: [Float] = []
    
    init(
        chatUser: ChatUser?,
        sendFileMessage: SendFileMessageUseCaseProtocol
    ) {
        self.chatUser = chatUser
        self.sendFileMessageUseCase = sendFileMessage
    }
    
    func handleSendFile(url: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendFileMessageResultMessage = try await sendFileMessageUseCase.excute(
                    url: url,
                    chatUser: chatUser
                )
                
                print(sendFileMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
}

extension AudioRecorderViewModel: AVAudioRecorderDelegate {
    
    func startRecording() {
        let date = Date()
        let fileURL = getDocumentsDirectory().appendingPathComponent("recording-\(date).m4a")

        let setting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("audioSession error: \(error.localizedDescription)")
        }

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: setting)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                self.audioRecorder.updateMeters()
                self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
                self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            })
            
            self.isRecording = true
        } catch {
            print("녹음 중 오류 발생: \(error.localizedDescription)")
        }
        
        self.isRecording = true

    }
    
    func stopRecording() {
        timer?.invalidate()
        audioRecorder.stop()
        recordedFiles.append(self.audioRecorder.url)
        isRecording = false
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
}

extension AudioRecorderViewModel: AVAudioPlayerDelegate {
    
    func startPlaying(recordingURL: URL) {
        let audioSession = AVAudioSession.sharedInstance()

        if isPaused {
            resumePlaying()
        } else {
            do {
                soundSamples.removeAll()

                try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try audioSession.setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: recordingURL)
                
                audioPlayer?.delegate = self
                audioPlayer?.isMeteringEnabled = true
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)

                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                    self.audioPlayer?.updateMeters()
                    self.soundSamples[self.currentSample] = self.audioPlayer?.averagePower(forChannel: 0) ?? 0
                    self.currentSample = (self.currentSample + 1) % self.numberOfSamples
                })
                
                isPlaying = true
                isPaused = false
                isEndPlay = false
            } catch {
                print("재생 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }
    
    func pausePlaying() {
        timer?.invalidate()
        audioPlayer?.pause()
        isPaused = true
        isPlaying = false
    }
    
    func resumePlaying() {
        audioPlayer?.play()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            self.audioPlayer?.updateMeters()
            self.soundSamples[self.currentSample] = self.audioPlayer?.averagePower(forChannel: 0) ?? 0
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
        isPaused = false
        isPlaying = true
    }
    
    func clearPlay() {
        timer?.invalidate()
        recordedFiles.removeAll()
        soundSamples.removeAll()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()

        isPlaying = false
        isPaused = false
        isEndPlay = true
        print("audioPlayerDidFinishPlaying")
    }
    
}
