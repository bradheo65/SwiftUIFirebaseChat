//
//  ChatMessageListenerRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol ChatMessageListenerRepositoryProtocol {
    
    func addChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void)
    func removeChatMessageListener()
    
}
