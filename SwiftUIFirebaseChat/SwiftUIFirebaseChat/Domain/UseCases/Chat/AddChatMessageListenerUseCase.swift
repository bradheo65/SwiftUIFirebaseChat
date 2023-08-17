//
//  AddChatMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol AddChatMessageListenerUseCaseProtocol {
    
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void)
    
}

final class AddChatMessageListenerUseCase: AddChatMessageListenerUseCaseProtocol {
    
    private let chatMessageListenerRepo: ChatMessageListenerRepositoryProtocol
    
    init(chatMessageListenerRepo: ChatMessageListenerRepositoryProtocol) {
        self.chatMessageListenerRepo = chatMessageListenerRepo
    }
    
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        chatMessageListenerRepo.addChatMessageListener(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                completion(.success(chatMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
