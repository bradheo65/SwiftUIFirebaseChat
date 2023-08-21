//
//  ChatListenerRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation

import Firebase

final class ChatListenerRepository: ChatListenerRepositoryProtocol {
    
    private let firebaseSerivce: FirebaseChatListenerProtocol
    
    init(firebaseSerivce: FirebaseChatListenerProtocol) {
        self.firebaseSerivce = firebaseSerivce
    }
    
    func startChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        firebaseSerivce.listenForChatMessage(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                completion(.success(chatMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func stopChatMessageListener() {
        firebaseSerivce.stopListenForChatMessage()
    }
    
    func startRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                completion(.success(documentChange))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func stopRecentMessageListener() {
        firebaseSerivce.stopListenForRecentMessage()
    }
    
}
