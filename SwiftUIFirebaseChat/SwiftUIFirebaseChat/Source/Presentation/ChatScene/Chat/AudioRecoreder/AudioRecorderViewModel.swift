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

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            print("audioSession error: \(error.localizedDescription)")
        }

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: setting)
            audioRecorder.delegate = self
            audioRecorder.record()
            self.isRecording = true
        } catch {
            print("녹음 중 오류 발생: \(error.localizedDescription)")
        }
        
        self.isRecording = true

    }
    
    func stopRecording() {
        audioRecorder.stop()
        self.recordedFiles.append(self.audioRecorder.url)
        isRecording = false
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AudioRecorderViewModel: AVAudioPlayerDelegate {
    
    func startPlaying(recordingURL: URL) {
        if isPaused {
            resumePlaying()
        } else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: recordingURL)
                
                audioPlayer?.delegate = self
                audioPlayer?.play()
                isPlaying = true
                isPaused = false
                isEndPlay = false
            } catch {
                print("재생 중 오류 발생: \(error.localizedDescription)")
            }
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPaused = true
        isPlaying = false
    }
    
    func pausePlaying() {
        audioPlayer?.pause()
        isPaused = true
        isPlaying = false
    }
    
    func resumePlaying() {
        audioPlayer?.play()
        isPaused = false
        isPlaying = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        isPaused = false
        isEndPlay = true
        print("audioPlayerDidFinishPlaying")
    }
    
}
