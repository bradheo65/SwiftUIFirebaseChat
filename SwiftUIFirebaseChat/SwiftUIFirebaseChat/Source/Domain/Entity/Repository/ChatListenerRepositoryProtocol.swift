//
//  ChatListenerRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import Firebase

protocol ChatListenerRepositoryProtocol {
    
    func startRealmChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatLog, Error>) -> Void)
    func startFirebaseChatMessageListener(chatUser: ChatUser)
    func stopChatMessageListener()
    func startRealmChatRoomListener(completion: @escaping (Result<ChatRoom, Error>) -> Void)
    func startFirebaseChatRoomListener()
    func stopRecentMessageListener()
    
}
