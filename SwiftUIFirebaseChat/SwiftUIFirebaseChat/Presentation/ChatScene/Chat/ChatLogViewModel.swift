//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation
import SwiftUI

import Photos

import AVFoundation

final class ChatLogViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    
    @Published var errorMessage = ""

    @Published var count = 0
    @Published var image: UIImage?
    @Published var isSaveCompleted = false
    @Published var isErrorAlert = false

    private let chatUser: ChatUser?
    
    private let addChatMessageListener = AddChatMessageListenerUseCase()
    private let removeChatMessageListenerUseCase = RemoveChatMessageListenerUseCase()
    private let sendMessageUseCase = SendTextMessageUseCase()
    private let sendImageMessageUseCase = SendImageMessageUseCase()
    private let sendVideoMessageUseCase = SendVideoMessageUseCase()
    private let sendFileMessageUseCase = SendFileMessageUseCase()

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
    }
    
    func addListener() {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        chatMessages.removeAll()
        
        addChatMessageListener.excute(chatUser: chatUser) { result in
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
        removeChatMessageListenerUseCase.excute()
    }
    
    func handleSendText(text: String, compltion: @escaping () -> Void) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        sendMessageUseCase.excute(text: text, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                print(message)
                compltion()
            case .failure(let error):
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
        
        sendImageMessageUseCase.excute(image: image, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleSendVideo(videoUrl: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        sendVideoMessageUseCase.excute(url: videoUrl, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleSendFile(fileUrl: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        sendFileMessageUseCase.excute(fileUrl: fileUrl, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
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
            let result = try await NetworkService.shared.downloadFile(url: fileInfo.url)
            
            switch result {
            case .success(let url):
                let result = try await FileSaveManager.shared.save(name: fileInfo.name, at: url)
                
                switch result {
                case .success(_):
                    DispatchQueue.main.sync {
                        self.isSaveCompleted.toggle()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
