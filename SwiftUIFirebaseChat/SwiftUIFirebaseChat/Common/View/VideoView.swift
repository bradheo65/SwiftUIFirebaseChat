//
//  VideoView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/02.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @Binding var videoUrl: String
    @Binding var videoEnd: Bool

    @State private var player = AVPlayer()
    
    @State private var videoStart: Bool = false

    var body: some View {
        ZStack {
            VideoPlayer(player: player)
            
            if videoStart == false {
                ProgressView()
                    .tint(.white)
            }
        }
        .onAppear {
            player = AVPlayer(url: URL(string: videoUrl)!)
            player.play()
            
           resgierNoti()
        }
        .onChange(of: videoEnd, perform: { newValue in
            player.pause()
            player.seek(to: .zero)
            dissNoti()
        })
        .ignoresSafeArea()
    }
    
    private func resgierNoti() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemNewAccessLogEntry, object: nil, queue: .main) { _ in
            print("ok?")
            videoStart.toggle()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            videoEnd = false
        }
    }
    
    private func dissNoti() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
