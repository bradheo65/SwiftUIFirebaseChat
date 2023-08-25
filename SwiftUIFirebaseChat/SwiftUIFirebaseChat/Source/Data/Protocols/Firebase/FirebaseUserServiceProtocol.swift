//
//  FirebaseUserServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/18.
//

import Foundation

protocol FirebaseUserServiceProtocol {
    
    var currentUser: ChatUser? { get }
    
    func registerUser(email: String, password: String) async throws -> String
    func saveUserInfo(store: String, currentUser: ChatUser, userData: [String: Any]) async throws -> String
    func loginUser(email: String, password: String) async throws -> String
    func logoutUser() throws -> String
    func fetchCurrentUser() async throws -> ChatUser?
    func fetchAllUsers() async throws -> [ChatUser]
    func deleteChatMessage(toId: String) async throws -> String
    func deleteRecentMessage(toId: String) async throws -> String
    
}
