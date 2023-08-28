//
//  UserRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import RealmSwift

enum UserError: Error {
    case currentUserNotFound
}

final class UserRepository: UserRepositoryProtocol {
    
    private let firebaseService: FirebaseUserServiceProtocol
    private let realm = try! Realm()

    init(firebaseService: FirebaseUserServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func registerUser(email: String, password: String) async throws -> String {
        return try await firebaseService.registerUser(email: email, password: password)
    }
    
    func saveUserInfo(email: String, password: String, profileImageUrl: URL, uid: String) async throws -> String {
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageURL: profileImageUrl.absoluteString
        ]
       
        let saveUserInfoResult = try await firebaseService.saveUserInfo(
            store: FirebaseConstants.users,
            uid: uid,
            userData: userData
        )
                
        return saveUserInfoResult
    }
    
    func loginUser(email: String, password: String) async throws -> String {
        let userUid = try await firebaseService.loginUser(email: email, password: password)
        
        DispatchQueue.main.async {
            let existingUser = self.realm.objects(CurrentUser.self).first?.email
            
            if email != existingUser {
                self.realm.writeAsync {
                    self.realm.deleteAll()
                }
            }
            let user = CurrentUser()
            
            user.uid = userUid
            user.email = email
            user.password = password
            
            self.realm.writeAsync {
                self.realm.create(CurrentUser.self, value: user, update: .modified)
            }
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        return userUid
    }
    
    func logoutUser() throws -> String {
        return try firebaseService.logoutUser()
    }
    
    func fetchCurrentUser() async throws -> ChatUser? {
        let currentUser = try await firebaseService.fetchCurrentUser()
                        
        DispatchQueue.main.async {
            if let user = self.realm.objects(CurrentUser.self).first {
                self.realm.writeAsync {
                    user.profileImageUrl = currentUser?.profileImageURL ?? ""
                }
            }
        }
        
        return currentUser
    }
    
    func fetchAllUsers() async throws -> [ChatUser] {
        let allUsers = try await firebaseService.fetchAllUsers()
        
        DispatchQueue.main.async {
            allUsers.forEach { user in
                let allUser = AllUsers()
                
                allUser.uid = user.uid
                allUser.email = user.email
                allUser.profileImageURL = user.profileImageURL
                
                self.realm.writeAsync {
                    self.realm.create(AllUsers.self, value: allUser, update: .modified)
                }
            }
        }
        
        return allUsers
    }
    
    func deleteChatMessage(toId: String) async throws -> String {
        DispatchQueue.main.async {
            let deleteMessage = self.realm.objects(ChatLog.self).filter("id == %@", toId)
            
            self.realm.writeAsync {
                deleteMessage.forEach { chatLog in
                    self.realm.delete(chatLog)
                }
            }
        }
        
        return try await firebaseService.deleteChatMessage(toId: toId)
    }
    
    func deleteRecentMessage(toId: String) async throws -> String {
        DispatchQueue.main.async {
            if let deleteMessage = self.realm.objects(ChatList.self).filter("id == %@", toId).first {
                self.realm.writeAsync {
                    self.realm.delete(deleteMessage)
                }
            }
        }
        
        return try await firebaseService.deleteRecentMessage(toId: toId)
    }
    
}


