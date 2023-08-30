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
    
    /**
     사용자 정보를 저장하는 함수

     이 함수는 주어진 사용자 정보를 사용하여 사용자의 이메일, 비밀번호, 프로필 이미지 URL, UID를 Firebase에 저장하는 역할을 합니다.
     사용자 정보를 사전 형태로 구성하여 Firebase의 `users` 컬렉션에 저장합니다.

     - Parameters:
       - email: 사용자의 이메일 주소
       - password: 사용자의 비밀번호
       - profileImageUrl: 사용자의 프로필 이미지 URL
       - uid: 사용자의 UID

     - Throws:
       - 기타 에러: 사용자 정보 저장 과정에서 발생한 에러를 전달

     - Returns: 사용자 정보 저장 결과 메시지
     */
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
    
    /**
     사용자 로그인 함수

     이 함수는 주어진 이메일과 비밀번호를 사용하여 사용자를 Firebase에 로그인하고, 로그인한 사용자 정보를 Realm에 저장하는 역할을 합니다.
     사용자가 로그인하면 현재 로그인한 사용자 정보를 `MyAccountInfo` 모델로 Realm에 저장합니다.

     - Parameters:
       - email: 사용자의 이메일 주소
       - password: 사용자의 비밀번호

     - Throws:
       - 기타 에러: 사용자 로그인 및 Realm 저장 과정에서 발생한 에러를 전달

     - Returns: 사용자 UID
     */
    func loginUser(email: String, password: String) async throws -> String {
        let userUid = try await firebaseService.loginUser(email: email, password: password)
        
        DispatchQueue.main.async {
            let existingUser = self.realm.objects(MyAccountInfo.self).first?.email
            
            // 이메일이 다른 사용자가 로그인했을 경우 기존 Realm 데이터를 삭제합니다.
            if email != existingUser {
                self.realm.writeAsync {
                    self.realm.deleteAll()
                }
            }
            
            // 로그인한 사용자 정보를 MyAccountInfo 모델로 구성하여 Realm에 저장합니다.
            let user = MyAccountInfo()
            
            user.uid = userUid
            user.email = email
            user.password = password
            
            self.realm.writeAsync {
                self.realm.create(MyAccountInfo.self, value: user, update: .modified)
            }
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        return userUid
    }
    
    /**
     사용자 로그아웃 함수

     이 함수는 Firebase에서 사용자 로그아웃을 수행하고, 로그아웃한 결과 메시지를 반환하는 역할을 합니다.

     - Throws:
       - 기타 에러: 사용자 로그아웃 과정에서 발생한 에러를 전달

     - Returns: 로그아웃 결과 메시지
     */
    func logoutUser() throws -> String {
        return try firebaseService.logoutUser()
    }
    
    /**
     현재 로그인한 사용자 정보를 가져오는 함수

     이 함수는 현재 로그인한 사용자의 정보를 Firebase에서 가져와서, 해당 정보를 Realm에 업데이트하는 역할을 합니다.
     가져온 사용자 정보 중 프로필 이미지 URL을 현재 로그인한 사용자의 Realm 데이터에 업데이트합니다.

     - Throws:
       - 기타 에러: 사용자 정보 가져오기 및 Realm 업데이트 과정에서 발생한 에러를 전달

     - Returns: 현재 로그인한 사용자 정보 (ChatUser 타입, nil 가능)
     */
    func fetchCurrentUser() async throws -> ChatUser? {
        let currentUser = try await firebaseService.fetchCurrentUser()
                        
        DispatchQueue.main.async {
            // 현재 로그인한 사용자의 Realm 데이터를 가져옵니다.
            if let myAccountInfo = self.realm.objects(MyAccountInfo.self).first {
                // 현재 사용자의 프로필 이미지 URL을 업데이트합니다.
                self.realm.writeAsync {
                    myAccountInfo.profileImageUrl = currentUser?.profileImageURL ?? ""
                }
            }
        }
        
        return currentUser
    }
    
    /**
     모든 사용자 정보를 가져오는 함수

     이 함수는 Firebase에서 모든 사용자의 정보를 가져와서 해당 정보를 Realm에 업데이트하는 역할을 합니다.
     가져온 사용자 정보를 사용하여 `FriendAccountInfo` 모델로 구성하여 Realm에 저장합니다.

     - Throws:
       - 기타 에러: 사용자 정보 가져오기 및 Realm 업데이트 과정에서 발생한 에러를 전달

     - Returns: 모든 사용자의 정보 (ChatUser 배열)
     */
    func fetchAllUsers() async throws -> [ChatUser] {
        let allUsers = try await firebaseService.fetchAllUsers()
        
        DispatchQueue.main.async {
            // 가져온 사용자 정보를 사용하여 FriendAccountInfo 모델로 구성하여 Realm에 저장합니다.
            allUsers.forEach { user in
                let friendAccountInfo = FriendAccountInfo()
                
                friendAccountInfo.uid = user.uid
                friendAccountInfo.email = user.email
                friendAccountInfo.profileImageURL = user.profileImageURL
                
                self.realm.writeAsync {
                    self.realm.create(FriendAccountInfo.self, value: friendAccountInfo, update: .modified)
                }
            }
        }
        
        return allUsers
    }
    
    /**
     특정 대화 메시지를 삭제하는 함수

     이 함수는 주어진 대화 메시지 ID에 해당하는 대화 메시지를 Realm에서 삭제하고, Firebase에서도 해당 메시지를 삭제하는 역할을 합니다.

     - Parameters:
       - toId: 채팅 받는 유저의 ID

     - Throws:
       - 기타 에러: 대화 메시지 삭제 과정에서 발생한 에러를 전달

     - Returns: 대화 메시지 삭제 결과 메시지
     */
    func deleteChatMessage(toId: String) async throws -> String {
        DispatchQueue.main.async {
            // 채팅 받는 유저의 ID에 해당하는 대화 메시지를 Realm에서 삭제합니다.
            let deleteMessage = self.realm.objects(ChatLog.self).filter("toId == %@", toId)
            
            self.realm.writeAsync {
                deleteMessage.forEach { chatLog in
                    self.realm.delete(chatLog)
                }
            }
        }
        
        return try await firebaseService.deleteChatMessage(toId: toId)
    }
    
    /**
     최근 대화 목록에서 특정 대화를 삭제하는 함수

     이 함수는 주어진 대화 메시지 ID에 해당하는 최근 대화 목록을 Realm에서 삭제하고, Firebase에서도 해당 대화 메시지를 삭제하는 역할을 합니다.

     - Parameters:
       - toId: 채팅 받는 유저의 ID

     - Throws:
       - 기타 에러: 대화 메시지 삭제 과정에서 발생한 에러를 전달

     - Returns: 대화 메시지 삭제 결과 메시지
     */
    func deleteRecentMessage(toId: String) async throws -> String {
        DispatchQueue.main.async {
            // 채팅 받는 유저의 ID에 해당하는 최근 대화 목록을 Realm에서 가져옵니다. Realm에서 삭제합니다.
            if let deleteMessage = self.realm.objects(ChatList.self).filter("toId == %@", toId).first {
                
                self.realm.writeAsync {
                    self.realm.delete(deleteMessage)
                }
            }
        }
        
        return try await firebaseService.deleteRecentMessage(toId: toId)
    }
    
}


