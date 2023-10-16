//
//  AudioRecorderView.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/04.
//

import SwiftUI

struct AudioRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let chatUser: ChatUser?
    
    @StateObject private var viewModel: AudioRecorderViewModel
    
    @State private var counter = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer? = nil
    @State private var value = 0
    @State private var pausedCounter: Int? = nil // 일시정지된 시간

    private var formattedTime: String {
        let minutes = (pausedCounter ?? counter) / 60
        let seconds = (pausedCounter ?? counter) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(
                chatUser: chatUser,
                sendFileMessage: Reslover.shared.resolve(SendFileMessageUseCaseProtocol.self)
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("음성메시지")
                .padding()
            
            HStack {
                if viewModel.recordedFiles.isEmpty == false {
                    if viewModel.isRecording == false {
                        Button {
                            viewModel.isPlaying
                            ? viewModel.pausePlaying()
                            : viewModel.startPlaying(recordingURL: viewModel.recordedFiles.first!)
                        } label: {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(viewModel.recordedFiles.isEmpty ? .black : .white)
                        }
                        .padding(.leading)
                    }
                }
                
                LottieView(
                    name: "animation_Play",
                    loopMode: .loop,
                    play: .constant(viewModel.isRecording || viewModel.isPlaying)
                )
                .id(value)
                
                Spacer()
                
                Text("\(formattedTime)")
                    .foregroundColor(viewModel.recordedFiles.isEmpty ? .black : .white)
                    .padding()
            }
            .background(Color(uiColor: viewModel.recordedFiles.isEmpty ? .secondarySystemFill : .systemPurple))
            .cornerRadius(16)

            HStack {
                Button("취소") {
                    dismiss()
                }
                
                Spacer()
                
                Button {
                    if viewModel.recordedFiles.isEmpty {
                        viewModel.isRecording
                        ? viewModel.stopRecording()
                        : viewModel.startRecording()
                        
                        viewModel.isRecording
                        ? startTimer()
                        : stopTimer()
                        value += 1
                    } else {
                        viewModel.recordedFiles.removeAll()
                        
                        clearTimer()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 45, height: 45)
                            .foregroundColor(Color(uiColor: .secondarySystemFill))
                        
                        if viewModel.recordedFiles.isEmpty {
                            if viewModel.isRecording {
                                Rectangle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.black)
                            } else {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.red)
                            }
                        } else {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    viewModel.handleSendFile(url: viewModel.recordedFiles.first!)
                } label: {
                    Text("Send")
                }
                .disabled(viewModel.recordedFiles.isEmpty)
            }
        }
        .padding()
        .onChange(of: viewModel.isPlaying) { newValue in
            value += 1
            
            if newValue {
                if viewModel.isPaused == false {
                    counter = 0
                }
                startTimer()
            } else {
                pauseTimer()
            }
        }
        .onChange(of: viewModel.isEndPlay) { newValue in
            if newValue {
                clearTimer()
            }
        }
    }
    
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            counter += 1
            if pausedCounter != nil {
                pausedCounter! += 1
            }
        }
    }

    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func clearTimer() {
        counter = 0
        pausedCounter = nil
        stopTimer()
    }
    
    func pauseTimer() {
        isTimerRunning = false
        pausedCounter = counter
        timer?.invalidate()
        timer = nil
    }
    
}

import Lottie

struct LottieView: UIViewRepresentable {
    private let name: String
    private let loopMode: LottieLoopMode
    private let contentMode: UIView.ContentMode
    @Binding var play: Bool
    
    private let animationView: LottieAnimationView

    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        play: Binding<Bool> = .constant(true)
    ) {
        self.name = name
        self.animationView = LottieAnimationView(name: name)
        self.loopMode = loopMode
        self.contentMode = contentMode
        self._play = play
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(animationView)
        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        animationView.loopMode = loopMode
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if play {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
}

