//
//  StartChatMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol StartChatMessageListenerUseCaseProtocol {
    
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void)
    
}

final class StartChatMessageListenerUseCase: StartChatMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        chatListenerRepo.startChatMessageListener(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                completion(.success(chatMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
