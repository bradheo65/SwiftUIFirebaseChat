//
//  ChatLogVIew.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import SwiftUI

struct ChatLogView: View {
    @StateObject private var viewModel: ChatLogViewModel
    
    @State private var image: UIImage?

    @State private var chatText = ""
    @State private var imageURL = ""

    @State private var shouldShowImagePicker = false
    @State private var shouldShowImageViewer = false

    private let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(chatUser: chatUser))
    }
    
    var body: some View {
        ZStack {
            messageView

            Text(viewModel.errorMessage)
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
        }
        .fullScreenCover(isPresented: $shouldShowImageViewer) {
            ImageViewer(imageURL: $imageURL)
        }
        .onChange(of: image) { newValue in
            viewModel.handleSendImage(image: newValue ?? UIImage())
        }
    }
    
}

extension ChatLogView {
    
    private var messageView: some View {
        ScrollView {
            ScrollViewReader { scollViewProxy in
                VStack {
                    ForEach(viewModel.chatMessages) { message in
                        messageView(message: message)
                    }
                    HStack { Spacer() }
                        .id("Empty")
                }
                .onReceive(viewModel.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scollViewProxy.scrollTo("Empty", anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground))
                .ignoresSafeArea()
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 8) {
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
            }
            
            ZStack {
                descriptionPlaceholder
                
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                viewModel.handleSendText(text: self.chatText) {
                    self.chatText = ""
                }
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var descriptionPlaceholder: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
    
    private func messageView(message: ChatMessage) -> some View {
        var imageMessageView: some View {
            ProfileImageView(url: message.imageUrl ?? "")
                .frame(
                    width: message.imageWidth,
                    height: message.imageHeight
                )
                .onTapGesture {
                    shouldShowImageViewer.toggle()
                    self.imageURL = message.imageUrl ?? ""
                }
        }
        
        var body: some View {
            VStack {
                if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                    HStack {
                        Spacer()
                        HStack {
                            if let text = message.text {
                                Text(text)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                            } else {
                                imageMessageView
                            }
                        }
                        .cornerRadius(8)
                    }
                } else {
                    HStack {
                        HStack {
                            if let text = message.text {
                                Text(text)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                            } else {
                                imageMessageView
                            }
                        }
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        return body
    }
    
}

struct ChatLogVIew_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
