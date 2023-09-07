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

    private let chatUser: ChatUser?

    @State private var selectedImage: UIImage?
    @State private var selectedImageFrame: CGRect?
    @State private var isImageTap = false
    @State private var isShowingImageViewer = false

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(
                chatUser: chatUser,
                sendTextMessage: Reslover.shared.resolve(SendTextMessageUseCaseProtocol.self),
                sendImageMessage: Reslover.shared.resolve(SendImageMessageUseCaseProtocol.self),
                sendVideoMessage: Reslover.shared.resolve(SendVideoMessageUseCaseProtocol.self),
                sendFileMessage: Reslover.shared.resolve(SendFileMessageUseCaseProtocol.self),
                fileSave: Reslover.shared.resolve(FileSaveUseCaseProtocol.self),
                startChatMessageListner: Reslover.shared.resolve(StartChatMessageListenerUseCaseProtocol.self),
                stopChatMessageListener: Reslover.shared.resolve(StopChatMessageListenerUseCaseProtocol.self)
            )
        )
    }
    
    var body: some View {
        ZStack {
            ChatMessageListView(
                viewModel: viewModel,
                chatUser: chatUser,
                selectedImage: $selectedImage,
                selectedImageFrame: $selectedImageFrame,
                isImageTap: $isImageTap
            )
            .opacity(isShowingImageViewer ? 0 : 1)
            .onTapGesture {
                hideKeyboard()
            }
            
            MessageImageViewer(
                viewModel: viewModel,
                selectedImage: $selectedImage,
                selectedImageFrame: $selectedImageFrame,
                isImageTap: $isImageTap,
                isShowingImageViewer: $isShowingImageViewer
            )
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !isShowingImageViewer {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                if !isShowingImageViewer {
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
    }
}

struct ChatLogVIew_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}

private struct ChatMessageListView: View {
    @ObservedObject private var viewModel: ChatLogViewModel
    
    private var chatUser: ChatUser?
    
    @Binding private var selectedImage: UIImage?
    @Binding private var selectedImageFrame: CGRect?
    @Binding private var isImageTap: Bool
    
    @State private var keyboardHeight: CGFloat = 0.0

    fileprivate init(
        viewModel: ChatLogViewModel,
        chatUser: ChatUser?,
        selectedImage: Binding<UIImage?>,
        selectedImageFrame: Binding<CGRect?>,
        isImageTap: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.chatUser = chatUser
        self._selectedImage = selectedImage
        self._selectedImageFrame = selectedImageFrame
        self._isImageTap = isImageTap
    }
    
    fileprivate var body: some View {
        ScrollView {
            ScrollViewReader { scollViewProxy in
                VStack {
                    ForEach(viewModel.chatMessages, id: \.self) { message in
                        ChatMessageCell(
                            viewModel: viewModel,
                            chatUser: chatUser,
                            message: message,
                            selectedImage: $selectedImage,
                            selectedImageFrame: $selectedImageFrame,
                            isImageTap: $isImageTap
                        )
                    }
                    Spacer()
                        .id("Empty")
                }
                .offset(y: -keyboardHeight) // 키보드가 올라올 때 화면을 위로 이동
                .animation(.easeInOut(duration: 0.5), value: keyboardHeight) // 애니메이션 추가
                .onReceive(viewModel.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scollViewProxy.scrollTo("Empty", anchor: .bottom)
                    }
                }
            }
        }
         .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
             if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                 self.keyboardHeight = keyboardFrame.height - 30
             }
         }
         .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
             self.keyboardHeight = 0.0
         }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            ChatInputView(
                viewModel: viewModel,
                chatUser: chatUser
            )
            .background(Color(.systemBackground))
            .ignoresSafeArea()
        }
    }
}

private struct ChatMessageCell: View {
    @ObservedObject private var viewModel: ChatLogViewModel
    
    private var chatUser: ChatUser?
    private var message: ChatLog
    
    @Binding private var selectedImage: UIImage?
    @Binding private var selectedImageFrame: CGRect?
    @Binding private var isImageTap: Bool
    
    fileprivate init(
        viewModel: ChatLogViewModel,
        chatUser: ChatUser?,
        message: ChatLog,
        selectedImage: Binding<UIImage?>,
        selectedImageFrame: Binding<CGRect?>,
        isImageTap: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.chatUser = chatUser
        self.message = message
        self._selectedImage = selectedImage
        self._selectedImageFrame = selectedImageFrame
        self._isImageTap = isImageTap
    }
    
    fileprivate var body: some View {
        VStack {
            HStack {
                if message.toId == chatUser?.uid {
                    Spacer()
                }
                HStack {
                    if let text = message.text {
                        Text(text)
                            .foregroundColor(message.toId == chatUser?.uid ? .white : .black)
                            .padding()
                            .background(message.toId == chatUser?.uid ? Color.purple : Color.white)
                    } else if message.fileUrl != nil {
                        FileMessageView(
                            viewModel: viewModel,
                            chatUser: chatUser,
                            message: message
                        )
                    } else {
                        ImageMessageView(
                            message: message,
                            selectedImage: $selectedImage,
                            selectedImageFrame: $selectedImageFrame,
                            isImageTap: $isImageTap
                        )
                    }
                }
                .cornerRadius(12, corners: [.topLeft, .bottomLeft, .bottomRight])
                
                if message.toId != chatUser?.uid {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

private struct ChatInputView: View {
    @ObservedObject private var viewModel: ChatLogViewModel
    
    private var chatUser: ChatUser?
    
    @State private var chatText = ""
    @State private var pickerImage: UIImage?
    @State private var videoUrl: URL?

    @State private var isShowingActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var isShowingFileImporter = false
    @State private var isShowingAudioRecorderView = false
    
    fileprivate init(
        viewModel: ChatLogViewModel,
        chatUser: ChatUser?
    ) {
        self.viewModel = viewModel
        self.chatUser = chatUser
    }
    
    fileprivate var body: some View {
        VStack {
            HStack(spacing: 8) {
                Button {
                    isShowingActionSheet.toggle()
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
                    viewModel.handleSendText(text: self.chatText)
                    chatText = ""
                } label: {
                    Text("보내기")
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
        .onChange(of: pickerImage) { newValue in
            viewModel.handleSendImage(image: newValue)
        }
        .onChange(of: videoUrl) { newValue in
            if let url = videoUrl {
                viewModel.handleSendVideo(url: url)
            }
        }
        .confirmationDialog("", isPresented: $isShowingActionSheet) {
            Button("사진 및 비디오 선택") {
                isShowingImagePicker.toggle()
            }
            Button("파일 선택") {
                isShowingFileImporter.toggle()
            }
            Button("음성 메세지 보내기") {
                isShowingAudioRecorderView.toggle()
            }
        }
        .fullScreenCover(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $pickerImage, videoUrl: $videoUrl)
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.pdf],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    viewModel.handleSendFile(url: url)
                    
                case .failure(let error):
                    print(error)
                }
        })
        .sheet(isPresented: $isShowingAudioRecorderView) {
            AudioRecorderView(chatUser: chatUser)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
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
}

private struct FileMessageView: View {
    @ObservedObject var viewModel: ChatLogViewModel
    
    private let chatUser: ChatUser?
    private var message: ChatLog
    
    @State private var isShowingFileSaveSheet = false
    @State private var fileInfo: FileInfo?

    fileprivate init(
        viewModel: ChatLogViewModel,
        chatUser: ChatUser?,
        message: ChatLog
    ) {
        self.viewModel = viewModel
        self.chatUser = chatUser
        self.message = message
    }
    
    fileprivate var body: some View {
        HStack {
            if message.fileType == "application/pdf" {
                Image(systemName: "folder.circle.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 40))
                    .onTapGesture {
                        isShowingFileSaveSheet.toggle()
                        
                        fileInfo = FileInfo(
                            url: URL(string: message.fileUrl ?? "")!,
                            name: message.fileTitle ?? "",
                            contentType: message.fileType ?? "",
                            size: message.fileSizes ?? ""
                        )
                    }
            } else {
                Image(systemName: (message.isPlay ?? false) ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(.purple)
                    .font(.system(size: 40))
                    .onTapGesture {
                        if let index = viewModel.chatMessages.firstIndex(where: {$0.uid == message.uid}) {
                            viewModel.getMessageIndex(index: index)
                        }
                        (message.isPlay ?? false)
                        ? viewModel.pausePlaying()
                        : viewModel.playAudio(url: URL(string: "\(message.fileUrl!).m4a")!)
                    }
            }
            
            VStack(alignment: .leading) {
                Text(message.fileTitle ?? "")
                    .font(.system(size: 14))
                    .lineLimit(2)
                Text(message.fileSizes ?? "")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: 250)
        .background(.white)
        .confirmationDialog("", isPresented: $isShowingFileSaveSheet) {
            Button("파일 저장") {
                viewModel.handleFileSave(fileInfo: fileInfo)
            }
        }
    }
}

private struct ImageMessageView: View {
    private var message: ChatLog

    @Binding private var selectedImage: UIImage?
    @Binding private var selectedImageFrame: CGRect?
    @Binding private var isImageTap: Bool
    
    @State private var shouldShowVideoViewer = false
    @State private var videoPlayUrl = ""

    fileprivate init(
        message: ChatLog,
        selectedImage: Binding<UIImage?>,
        selectedImageFrame: Binding<CGRect?>,
        isImageTap: Binding<Bool>
    ) {
        self.message = message
        self._selectedImage = selectedImage
        self._selectedImageFrame = selectedImageFrame
        self._isImageTap = isImageTap
    }
    
    fileprivate var body: some View {
        ZStack {
            RemoteImage(
                imageLoader: ImageLoader(url: message.imageUrl ?? ""),
                imageData: $selectedImage,
                imageFrame: $selectedImageFrame,
                isImageTap: $isImageTap
            )
            .disabled(message.videoUrl != nil)
            
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
            width: CGFloat(message.imageWidth ?? .zero),
            height: CGFloat(message.imageHeight ?? .zero)
        )
    }
}

private struct MessageImageViewer: View {
    @ObservedObject private var viewModel: ChatLogViewModel

    @Binding private var selectedImage: UIImage?
    @Binding private var selectedImageFrame: CGRect?
    @Binding private var isImageTap: Bool
    @Binding private var isShowingImageViewer: Bool
    
    @State private var isHiddenImageViewer = true
    @State private var savePhoto = false
    
    fileprivate init(
        viewModel: ChatLogViewModel,
        selectedImage: Binding<UIImage?>,
        selectedImageFrame: Binding<CGRect?>,
        isImageTap: Binding<Bool>,
                        isShowingImageViewer: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._selectedImage = selectedImage
        self._selectedImageFrame = selectedImageFrame
        self._isImageTap = isImageTap
        self._isShowingImageViewer = isShowingImageViewer
    }
    
    fileprivate var body: some View {
        GeometryReader { reader in
            ImageViewer(
                uIimage: $selectedImage,
                show: $isShowingImageViewer,
                hide: $isHiddenImageViewer,
                savePhoto: $savePhoto
            )
            .frame(
                width: isShowingImageViewer ? reader.size.width : selectedImageFrame?.width,
                height: isShowingImageViewer ? reader.size.height : selectedImageFrame?.height
            )
            .position(
                x: isShowingImageViewer ? reader.frame(in: .global).midX : selectedImageFrame?.midX ?? .zero,
                y: isShowingImageViewer ? reader.frame(in: .global).midY : selectedImageFrame?.midY ?? .zero
            )
            .if(isHiddenImageViewer, transform: { view in
                view.hidden()
            })
                .ignoresSafeArea()
        }
        .onChange(of: isImageTap, perform: { newValue in
            isHiddenImageViewer.toggle()

            withAnimation(.easeOut(duration: 0.2)) {
                hideKeyboard()
                isShowingImageViewer.toggle()
            }
        })
        .alert("사진 앱에 저장하시겠습니까?", isPresented: $savePhoto) {
            Button { } label: {
                Text("Cancel")
            }
            Button {
                viewModel.handleImageSave(image: selectedImage ?? UIImage())
            } label: {
                Text("OK")
            }
        }
        .alert("저장이 완료되었습니다.", isPresented: $viewModel.isSaveCompleted) {
            Button { } label: {
                Text("OK")
            }
        }
    }
}
