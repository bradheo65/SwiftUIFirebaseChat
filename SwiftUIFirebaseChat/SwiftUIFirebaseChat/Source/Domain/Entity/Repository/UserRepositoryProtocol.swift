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
    func fetchAllUsers() async throws -> [ChatUser]
    func deleteChatMessage(toId: String) async throws -> String
    func deleteRecentMessage(toId: String) async throws -> String
    
}
