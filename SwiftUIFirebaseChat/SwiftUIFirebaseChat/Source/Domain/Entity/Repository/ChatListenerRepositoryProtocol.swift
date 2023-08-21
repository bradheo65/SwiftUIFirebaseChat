//
//  ChatListenerRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import Firebase

protocol ChatListenerRepositoryProtocol {
    
    func startChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void)
    func stopChatMessageListener()
    func startRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void)
    func stopRecentMessageListener()
    
}
