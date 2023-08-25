//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation
import SwiftUI

final class ChatLogViewModel: ObservableObject {
    
    @Published var chatMessages: [ChatMessage] = []
    
    @Published var errorMessage = ""

    @Published var count = 0
    @Published var image: UIImage?
    @Published var isSaveCompleted = false
    @Published var isErrorAlert = false

    private let chatUser: ChatUser?
    
    private let sendMessageUseCase: SendTextMessageUseCaseProtocol
    private let sendImageMessageUseCase: SendImageMessageUseCaseProtocol
    private let sendVideoMessageUseCase: SendVideoMessageUseCaseProtocol
    private let sendFileMessageUseCase: SendFileMessageUseCaseProtocol
    private let fileSave: FileSaveUseCaseProtocol
    private let startChatMessageListener: StartChatMessageListenerUseCaseProtocol
    private let stopChatMessageListenerUseCase: StopChatMessageListenerUseCaseProtocol

    init(
        chatUser: ChatUser?,
        sendTextMessage: SendTextMessageUseCaseProtocol,
        sendImageMessage: SendImageMessageUseCaseProtocol,
        sendVideoMessage: SendVideoMessageUseCaseProtocol,
        sendFileMessage: SendFileMessageUseCaseProtocol,
        fileSave: FileSaveUseCaseProtocol,
        startChatMessageListner: StartChatMessageListenerUseCaseProtocol,
        stopChatMessageListener: StopChatMessageListenerUseCaseProtocol
    ) {
        self.chatUser = chatUser
        self.sendMessageUseCase = sendTextMessage
        self.sendImageMessageUseCase = sendImageMessage
        self.sendVideoMessageUseCase = sendVideoMessage
        self.sendFileMessageUseCase = sendFileMessage
        self.fileSave = fileSave
        self.startChatMessageListener = startChatMessageListner
        self.stopChatMessageListenerUseCase = stopChatMessageListener
    }
    
    func addListener() {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        chatMessages.removeAll()
        
        startChatMessageListener.excute(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                self.chatMessages.append(chatMessage)
                
                // ScollViewProxy receiver
                DispatchQueue.main.async {
                    self.count += 1
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func removeListener() {
        stopChatMessageListenerUseCase.excute()
    }
    
    func handleSendText(text: String) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }

        Task {
            do {
                let sendMessageResultMessage = try await sendMessageUseCase.execute(text: text, chatUser: chatUser)
                
                print(sendMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
     
    func handleSendImage(image: UIImage?) {
        guard let image = image else {
            print("Fail to image load")
            return
        }
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendImageMessageResultMessage = try await sendImageMessageUseCase.excute(image: image, chatUser: chatUser)
                
                print(sendImageMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    func handleSendVideo(videoUrl: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendVideoMessageResultMessage = try await sendVideoMessageUseCase.excute(url: videoUrl, chatUser: chatUser)
                
                print(sendVideoMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    func handleSendFile(fileUrl: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendFileMessageResultMessage = try await sendFileMessageUseCase.excute(fileUrl: fileUrl, chatUser: chatUser)
                
                print(sendFileMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    func handleImageSave(image: UIImage) {
        ImageSaveManager.shared.writeToPhotoAlbum(image: image)
        
        ImageSaveManager.shared.successHandler = {
            self.isSaveCompleted.toggle()
        }
        
        ImageSaveManager.shared.errorHandler = {
            self.isErrorAlert.toggle()
            self.errorMessage = $0.localizedDescription
        }
    }
    
    func handleFileSave(fileInfo: FileInfo?) {
        guard let fileInfo = fileInfo else {
            print("Fail to file load")
            return
        }
        
        Task {
            do {
                let url = try await fileSave.excute(url: fileInfo.url)
                
                let message = try await FileSaveManager.shared.save(name: fileInfo.name, at: url)
                
                print(message)
                DispatchQueue.main.sync {
                    self.isSaveCompleted.toggle()
                }
            } catch {
                print(error)
            }
        }
    }
    
}
