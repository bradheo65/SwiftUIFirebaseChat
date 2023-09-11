//
//  UserRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation

protocol UserRepositoryProtocol {
    
    func registerUser(email: String, password: String) async throws -> String
    func saveUserInfo(email: String, password: String, profileImageUrl: URL, uid: String) async throws -> String
    func loginUser(email: String, password: String) async throws -> String
    func logoutUser() throws -> String
    func fetchCurrentUser() async throws -> ChatUser?
    func fetchFirebaseFriendList() async throws -> [ChatUser]
    func saveRealmFriendList(chatUser: [ChatUser])
    func fetchRealmFriendList() -> [ChatUser]
    func deleteChatMessage(id: String, toId: String) async throws -> String
    func deleteRecentMessage(id: String, toId: String) async throws -> String
    
}
