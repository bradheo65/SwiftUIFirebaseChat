//
//  ChatMessageListenerRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

struct ChatMessageListenerRepository: ChatMessageListenerRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func addChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        firebaseService.addChatMessageListener(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                completion(.success(chatMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeChatMessageListener() {
        firebaseService.removeChatMessageListener()
    }
}
