//
//  FirebaseChatListenerProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation

import Firebase

protocol FirebaseChatListenerProtocol {
    
    func fetchMessage(chatUser: ChatUser) async throws -> [ChatMessageResponseDTO]
    func listenForChatMessage(chatUser: ChatUser, completion: @escaping (Result<DocumentChange, Error>) -> Void)
    func stopListenForChatMessage()
    func listenForRecentMessage(completion: @escaping (Result<DocumentChange, Error>) -> Void)
    func stopListenForRecentMessage()
    
}
