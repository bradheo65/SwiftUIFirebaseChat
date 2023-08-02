//
//  ChatLogVIew.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import SwiftUI

struct ChatLogView: View {
    @StateObject private var viewModel: ChatLogViewModel
    
    @State private var pickerImage: UIImage?
    @State private var tapImage: UIImage?
    @State private var fileURL: URL?

    @State private var chatText = ""
    
    @State private var tapImageFrame: CGRect?

    @State private var shouldShowImagePicker = false
    @State private var shouldShowImageViewer = false
    @State private var shouldHideImageViewer = true
    @State private var isImageTap = false

    private let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(chatUser: chatUser))
    }
    
    var body: some View {
        GeometryReader { reader in
            
            ZStack {
                messageView
                    .opacity(shouldShowImageViewer ? 0 : 1)
                
                ImageViewer(uIimage: $tapImage, show: $shouldShowImageViewer, end: $shouldHideImageViewer)
                    .frame(
                        width: shouldShowImageViewer ? reader.size.width : tapImageFrame?.width,
                        height: shouldShowImageViewer ? reader.size.height : tapImageFrame?.height
                    )
                    .position(
                        x: shouldShowImageViewer ? reader.frame(in: .global).midX : tapImageFrame?.midX ?? .zero,
                        y: shouldShowImageViewer ? reader.frame(in: .global).midY : tapImageFrame?.midY ?? .zero
                    )
                    .if(shouldHideImageViewer, transform: { view in
                        view.hidden()
                    })
                    .ignoresSafeArea()
                        
                Text(viewModel.errorMessage)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !shouldShowImageViewer {
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if !shouldShowImageViewer {
                    
                    VStack {
                        Text(chatUser?.email ?? "")
                    }
                }
            }
                
        }
        .onDisappear {
            viewModel.firestoreListener?.remove()
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $pickerImage, fileURL: $fileURL)
        }
        .onChange(of: pickerImage) { newValue in
            viewModel.handleSendImage(image: newValue ?? UIImage())
        }
        .onChange(of: fileURL) { newValue in
            if let url = fileURL {
                viewModel.handleSendVideo(fileUrl: url)
            }
         }
        .onChange(of: isImageTap, perform: { newValue in
            shouldHideImageViewer.toggle()
            
            withAnimation(.easeOut(duration: 0.2)) {
                shouldShowImageViewer.toggle()
            }
        })
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
            RemoteImage(
                imageLoader: ImageLoader(url: message.imageUrl ?? ""),
                tapImage: $tapImage,
                imageFrame: $tapImageFrame,
                isImageTap: $isImageTap
            )
            .frame(
                width: message.imageWidth,
                height: message.imageHeight
            )
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
