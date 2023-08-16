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

struct AddChatMessageListenerUseCase: AddChatMessageListenerUseCaseProtocol {
    
    private let chatMessageListenerRepo = ChatMessageListenerRepository()
    
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
