//
//  ChatListenerRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import Firebase

protocol ChatListenerRepositoryProtocol {
    
    func fetchUserChatMessage(chatUser: ChatUser) async throws
    func checkChatUserUID(chatUserUID: String?, completion: @escaping (String) -> Void)
    func startRealmConversationListener(chatUserUID: String?, completion: @escaping (String) -> Void)
    func startRealmChatMessageListener(chatRoomID: String, completion: @escaping (Result<ChatLog, Error>) -> Void)
    func startFirebaseChatMessageListener(chatUser: ChatUser, chatRoomID: String)
    func stopChatMessageListener()
    func startRealmChatRoomListener(completion: @escaping (Result<ChatRoom, Error>) -> Void)
    func startFirebaseChatRoomListener()
    func stopRecentMessageListener()
    
}
