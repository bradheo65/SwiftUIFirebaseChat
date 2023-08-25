//
//  UserRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

enum UserError: Error {
    case currentUserNotFound
}

final class UserRepository: UserRepositoryProtocol {
    
    private let firebaseService: FirebaseUserServiceProtocol
    
    init(firebaseService: FirebaseUserServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func registerUser(email: String, password: String) async throws -> String {
        return try await firebaseService.registerUser(email: email, password: password)
    }
    
    func saveUserInfo(email: String, profileImageUrl: URL) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: currentUser.uid,
            FirebaseConstants.profileImageURL: profileImageUrl.absoluteString
        ]
       
        let saveUserInfoResult = try await firebaseService.saveUserInfo(store: FirebaseConstants.users, currentUser: currentUser, userData: userData)
        
        return saveUserInfoResult
    }
    
    func loginUser(email: String, password: String) async throws -> String {
        return try await firebaseService.loginUser(email: email, password: password)
    }
    
    func logoutUser() throws -> String {
        return try firebaseService.logoutUser()
    }
    
    func fetchCurrentUser() async throws -> ChatUser? {
        return try await firebaseService.fetchCurrentUser()
    }
    
    func fetchAllUsers() async throws -> [ChatUser] {
        return try await firebaseService.fetchAllUsers()
    }
    
    func deleteChatMessage(toId: String) async throws -> String {
        return try await firebaseService.deleteChatMessage(toId: toId)
    }
    
    func deleteRecentMessage(toId: String) async throws -> String {
        return try await firebaseService.deleteRecentMessage(toId: toId)
    }
    
}


