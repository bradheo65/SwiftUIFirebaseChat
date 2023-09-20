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
    private let dataSource: RealmDataSourceProtocol

    init(firebaseService: FirebaseUserServiceProtocol, dataSource: RealmDataSourceProtocol) {
        self.firebaseService = firebaseService
        self.dataSource = dataSource
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
        let recentLoginUserEmail = self.dataSource.read(LoginUser.self).first?.email
        
        // 이메일이 다른 사용자가 로그인했을 경우 기존 Realm 데이터를 삭제합니다.
        if email != recentLoginUserEmail {
            self.dataSource.deleteAll()
        }
        
        // 로그인한 사용자 정보를 MyAccountInfo 모델로 구성하여 Realm에 저장합니다.
        let loginUser = LoginUser()
        
        loginUser.uid = userUid
        loginUser.email = email
        loginUser.password = password
        
        self.dataSource.create(LoginUser.self, value: loginUser)
                
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
        
        guard let loginUser = self.dataSource.read(LoginUser.self).first else {
            throw UserError.currentUserNotFound
        }

        self.dataSource.update {
            loginUser.profileImageURL = currentUser?.profileImageURL ?? ""
        }
        
        let user = ChatUser(
            uid: loginUser.uid,
            email: loginUser.email,
            profileImageURL: loginUser.profileImageURL
        )
        
        return user
    }
    
    /**
     모든 사용자 정보를 가져오는 함수

     이 함수는 Firebase에서 모든 사용자의 정보를 가져와서 해당 정보를 Realm에 업데이트하는 역할을 합니다.
     가져온 사용자 정보를 사용하여 `FriendAccountInfo` 모델로 구성하여 Realm에 저장합니다.
     그리고 Realm에 저장되어 있는 정보를 `ChatUser` 모델로 재 구성하여 반환 합니다.

     - Throws:
       - 기타 에러: 사용자 정보 가져오기 및 Realm 업데이트 과정에서 발생한 에러를 전달

     - Returns: 모든 사용자의 정보 (ChatUser 배열)
     */
    func fetchFirebaseFriendList() async throws -> [ChatUser] {
        return try await firebaseService.fetchAllUsers()
    }
    
    func saveRealmFriendUser(chatUser: [ChatUser]) {
        chatUser.forEach { user in
            let friendUser = FriendUser()
            
            friendUser.uid = user.uid
            friendUser.email = user.email
            friendUser.profileImageURL = user.profileImageURL
            
            self.dataSource.create(FriendUser.self, value: friendUser)
        }
    }
    
    func fetchRealmFriendUser() -> [ChatUser] {
        var friendUsers: [ChatUser] = []
        
        dataSource.read(FriendUser.self).forEach { info in
            let user = ChatUser(
                uid: info.uid,
                email: info.email,
                profileImageURL: info.profileImageURL
            )
            friendUsers.append(user)
        }
        
        return friendUsers
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
    func deleteChatMessage(id: String, toId: String) async throws -> String {
        // 채팅 받는 유저의 ID에 해당하는 대화 메시지를 Realm에서 삭제합니다.
        
        // Message 삭제
        let conversation = dataSource.read(Conversation.self).filter("room.id == %@", id)
        
        conversation.first?.messages.forEach { message in
            dataSource.delete(dataSource.read(Message.self).filter("id == %@", message.id).first!)
        }
        dataSource.delete(conversation.first!)

        // Room 삭제
        let room = dataSource.read(Room.self).filter("id == %@", id)
        
        dataSource.delete(room.first!)
        
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
    func deleteRecentMessage(id: String, toId: String) async throws -> String {
        // 채팅 받는 유저의 ID에 해당하는 최근 대화 목록을 Realm에서 가져옵니다. Realm에서 삭제합니다.
        if let deleteMessage = self.dataSource.read(Room.self).filter("id == %@", id).first {
            self.dataSource.delete(deleteMessage)
        }
        
        return try await firebaseService.deleteRecentMessage(toId: toId)
    }
}
