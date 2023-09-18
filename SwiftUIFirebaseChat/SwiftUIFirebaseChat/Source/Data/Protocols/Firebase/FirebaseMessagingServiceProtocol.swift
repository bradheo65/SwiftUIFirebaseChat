//
//  FirebaseMessagingServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import SwiftUI

import Firebase

protocol FirebaseMessagingServiceProtocol {
    
    var currentUser: ChatUser? { get }
    var timeStamp: Timestamp { get }
  
    func fetchMessage(chatUser: ChatUser) async throws -> [ChatMessageResponseDTO]
    func sendMessage(fromId: String, toId: String, messageData: [String: Any]) async throws -> String
    func sendRecentMessage(text: String, currentUser: ChatUser, chatUser: ChatUser, userMessage: [String: Any], recentMessage: [String: Any]) async throws -> String
    
}
