//
//  ChatLogVIew.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import SwiftUI

struct ChatLogView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ChatLogViewModel
    
    @State private var fileInfo: FileInfo?

    @State private var pickerImage: UIImage?
    @State private var imageData: UIImage?
    @State private var videoUrl: URL?
    
    @State private var chatText = ""
    
    @State private var videoPlayUrl = ""

    @State private var shouldShowActionSheet = false
    @State private var shouldShowFireSaveActionSheet = false

    @State private var shouldShowImagePicker = false
    @State private var shouldShowFilePicker = false
    
    @State private var shouldShowImageViewer = false
    @State private var shouldShowVideoViewer = false
    @State private var savePhoto = false

    @State private var shouldHideImageViewer = true

    @State private var isImageTap = false
    @State private var tapImageFrame: CGRect?

    private let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(
                chatUser: chatUser,
                sendTextMessage: Reslover.shared.resolve(SendTextMessageUseCaseProtocol.self),
                sendImageMessage: Reslover.shared.resolve(SendImageMessageUseCaseProtocol.self),
                sendVideoMessage: Reslover.shared.resolve(SendVideoMessageUseCaseProtocol.self),
                sendFileMessage: Reslover.shared.resolve(SendFileMessageUseCaseProtocol.self),
                addChatMessageListner: Reslover.shared.resolve(AddChatMessageListenerUseCaseProtocol.self),
                removeChatMessageListener: Reslover.shared.resolve(RemoveChatMessageListenerUseCaseProtocol.self)
            )
        )
    }
    
    var body: some View {
        ZStack {
            messageView
                .opacity(shouldShowImageViewer ? 0 : 1)
            
            imageViewer
            
            Text(viewModel.errorMessage)
        }
        
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !shouldShowImageViewer {
                    Button {
                        dismiss()
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
        .onAppear {
            viewModel.addListener()
        }
        .onDisappear {
            viewModel.removeListener()
        }
        .onChange(of: pickerImage) { newValue in
            viewModel.handleSendImage(image: newValue)
        }
        .onChange(of: videoUrl) { newValue in
            if let url = videoUrl {
                viewModel.handleSendVideo(videoUrl: url)
            }
        }
        .onChange(of: isImageTap, perform: { newValue in
            shouldHideImageViewer.toggle()
            
            withAnimation(.easeOut(duration: 0.2)) {
                shouldShowImageViewer.toggle()
            }
        })
        .fileImporter(
            isPresented: $shouldShowFilePicker,
            allowedContentTypes: [.pdf],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    print(url)
                    viewModel.handleSendFile(fileUrl: url)
                    
                case .failure(let error):
                    print(error)
                }
        })
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $pickerImage, videoUrl: $videoUrl)
        }
        .confirmationDialog("", isPresented: $shouldShowActionSheet) {
            Button("사진 및 비디오 선택") {
                shouldShowImagePicker.toggle()
            }
            Button("파일 선택") {
                shouldShowFilePicker.toggle()
            }
        }
        .confirmationDialog("", isPresented: $shouldShowFireSaveActionSheet) {
            Button("파일 저장") {
                viewModel.handleFileSave(fileInfo: fileInfo)
            }
        }
        .alert("사진 앱에 저장하시겠습니까?", isPresented: $savePhoto) {
            Button { } label: {
                Text("Cancel")
            }
            Button {
                viewModel.handleImageSave(image: imageData ?? UIImage())
            } label: {
                Text("OK")
            }
        }
        .alert("저장이 완료되었습니다.", isPresented: $viewModel.isSaveCompleted) {
            Button { } label: {
                Text("OK")
            }
        }
        .alert("Error", isPresented: $viewModel.isErrorAlert) {
            Button { } label: {
                Text("OK")
            }
        } message: {
            Text(viewModel.errorMessage)
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
    
    private var imageViewer: some View {
        GeometryReader { reader in
            ImageViewer(
                uIimage: $imageData,
                show: $shouldShowImageViewer,
                hide: $shouldHideImageViewer,
                savePhoto: $savePhoto
            )
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
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 8) {
            Button {
                shouldShowActionSheet.toggle()
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.black)
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
            .background(Color.purple)
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
        var imageMessage: some View {
            ZStack {
                RemoteImage(
                    imageLoader: ImageLoader(url: message.imageUrl ?? ""),
                    imageData: $imageData,
                    imageFrame: $tapImageFrame,
                    isImageTap: $isImageTap
                )
                .disabled((message.videoUrl != nil))
                
                if message.videoUrl != nil {
                    if shouldShowVideoViewer {
                        VideoPlayerView(
                            videoUrl: $videoPlayUrl,
                            videoEnd: $shouldShowVideoViewer
                        )
                    } else {
                        Button {
                            videoPlayUrl = message.videoUrl ?? ""
                            shouldShowVideoViewer.toggle()
                        } label: {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                    }
                }
            }
            .frame(
                width: message.imageWidth,
                height: message.imageHeight
            )
        }
        
        var fileMessage: some View {
            HStack {
                Image(systemName: "folder.circle.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 40))

                VStack(alignment: .leading) {
                    Text(message.fileTitle)
                        .font(.system(size: 14))
                        .lineLimit(2)
                    Text(message.fileSizes)
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: 250)
            .background(.white)
            .onTapGesture {
                shouldShowFireSaveActionSheet.toggle()
                
                fileInfo = FileInfo(
                    url: URL(string: message.fileUrl ?? "")!,
                    name: message.fileTitle,
                    contentType: message.fileType ?? "",
                    size: message.fileSizes
                )
            }
        }
        
        var body: some View {
            VStack {
                if message.toId == chatUser?.uid {
                    HStack {
                        Spacer()
                        
                        HStack {
                            if let text = message.text {
                                Text(text)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                            } else if message.fileUrl != nil {
                                fileMessage
                            } else {
                                imageMessage
                            }
                        }
                        .cornerRadius(12, corners: .topLeft)
                        .cornerRadius(12, corners: .bottomLeft)
                        .cornerRadius(12, corners: .bottomRight)
                    }
                } else {
                    HStack {
                        HStack {
                            if let text = message.text {
                                Text(text)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                            } else if message.fileUrl != nil {
                                fileMessage
                            } else {
                                imageMessage
                            }
                        }
                        .cornerRadius(12, corners: .topRight)
                        .cornerRadius(12, corners: .bottomLeft)
                        .cornerRadius(12, corners: .bottomRight)
                        
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
