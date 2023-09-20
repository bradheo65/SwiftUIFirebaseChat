//
//  MessagingRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

final class MessagingRepository: MessagingRepositoryProtocol {
    private let firebaseService: FirebaseMessagingServiceProtocol
    private let dataSource: RealmDataSourceProtocol

    init(
        firebaseService: FirebaseMessagingServiceProtocol,
        dataSource: RealmDataSourceProtocol
    ) {
        self.firebaseService = firebaseService
        self.dataSource = dataSource
    }
    
    /**
     Realm에 저장되어 있는 메시지를 가져오는 함수
     
     이 함수는 Realm에 저장되어 있는 메시지를 반환하는 역할을 합니다.
     
     - Parameters:
     - chatUser: 대화 상대의 ChatUser 정보
     
     - Returns: 메시지
     */
    func fetchChatMessage(chatRoomID: String, completion: @escaping (ChatLog) -> Void) {
        let messages = dataSource.read(Conversation.self).filter("room.id == %@", chatRoomID).first?.messages.reversed().prefix(10)
        
        if messages?.isEmpty == false {
            messages?.forEach { log in
                completion(log.toDomain())
            }
        }
    }
        
    /**
     Realm에 저장되어 있는 메시지를 date의 기준으로 가져오는 함수
     
     이 함수는 Realm에 저장되어 있는 메시지를 date의 기준으로 반환하는 역할을 합니다.
     
     - Parameters:
     - date: 가져오는 메세지의 날짜 기준 정보
     - chatUser: 대화 상대의 ChatUser 정보
     
     - Returns: 메시지
     */
    func fetchNextChatMessage(from date: Date?, chatRoomID: String, completion: @escaping (ChatLog) -> Void) {
        guard let date = date else {
            print("no Date")
            return
        }
        
        let messages = dataSource.read(Conversation.self).filter("room.id == %@", chatRoomID, date).first?.messages.filter("timestamp < %@", date).reversed().prefix(10)
        
        if messages?.isEmpty == false {
            messages?.forEach { log in
                completion(log.toDomain())
            }
        }
    }
    
    /**
     텍스트 메시지를 전송하는 함수

     이 함수는 주어진 텍스트 메시지를 Firebase에 전송하고, 전송된 메시지의 결과를 반환하는 역할을 합니다.

     - Parameters:
       - text: 전송할 텍스트 메시지
       - chatUser: 대화 상대의 ChatUser 정보

     - Throws:
       - UserError.currentUserNotFound: 현재 사용자 정보를 찾을 수 없을 경우 에러를 던짐

     - Returns: 전송 결과 메시지
     */
    func sendText(text: String, chatUser: ChatUser) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Text.text: text,
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]
        
        let sendMessage = try await firebaseService.sendMessage(
            fromId: currentUser.uid,
            toId: chatUser.uid,
            messageData: messageData
        )
        
        return sendMessage
    }
    
    /**
     이미지를 전송하는 함수

     이 함수는 주어진 이미지와 이미지 URL을 Firebase에 전송하고, 전송된 이미지 메시지의 결과를 반환하는 역할을 합니다.

     - Parameters:
       - url: 이미지의 URL
       - image: 전송할 이미지
       - chatUser: 대화 상대의 ChatUser 정보

     - Throws:
       - UserError.currentUserNotFound: 현재 사용자 정보를 찾을 수 없을 경우 에러를 던짐

     - Returns: 전송 결과 메시지
     */
    func sendImage(url: URL, image: UIImage, chatUser: ChatUser) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Image.url: url.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]
        
        let sendMessage = try await firebaseService.sendMessage(
            fromId: currentUser.uid,
            toId: chatUser.uid,
            messageData: messageData
        )
        
        return sendMessage
    }
    
    /**
     비디오를 전송하는 함수

     이 함수는 주어진 이미지 URL, 비디오 URL, 이미지와 함께 Firebase에 비디오 메시지를 전송하고, 전송 결과를 반환하는 역할을 합니다.

     - Parameters:
       - imageUrl: 비디오 썸네일 이미지의 URL
       - videoUrl: 전송할 비디오의 URL
       - image: 비디오 썸네일 이미지
       - chatUser: 대화 상대의 ChatUser 정보

     - Throws:
       - UserError.currentUserNotFound: 현재 사용자 정보를 찾을 수 없을 경우 에러를 던짐

     - Returns: 전송 결과 메시지
     */
    func sendVideo(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Image.url: imageUrl.absoluteString,
            FirebaseConstants.Video.url: videoUrl.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]
        
        let sendMessage = try await firebaseService.sendMessage(
            fromId: currentUser.uid,
            toId: chatUser.uid,
            messageData: messageData
        )
        
        return sendMessage
    }
    
    /**
     파일을 전송하는 함수

     이 함수는 주어진 파일 정보와 대화 상대의 ChatUser 정보를 Firebase에 전송하고, 전송 결과를 반환하는 역할을 합니다.

     - Parameters:
       - fileInfo: 전송할 파일의 정보 (FileInfo)
       - chatUser: 대화 상대의 ChatUser 정보

     - Throws:
       - UserError.currentUserNotFound: 현재 사용자 정보를 찾을 수 없을 경우 에러를 던짐

     - Returns: 전송 결과 메시지
     */
    func sendFile(fileInfo: FileInfo, chatUser: ChatUser) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.File.url: fileInfo.url.absoluteString,
            FirebaseConstants.File.name: fileInfo.name,
            FirebaseConstants.File.type: fileInfo.contentType,
            FirebaseConstants.File.size: fileInfo.size,
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]
        
        let sendMessage = try await firebaseService.sendMessage(
            fromId: currentUser.uid,
            toId: chatUser.uid,
            messageData: messageData
        )
        
        return sendMessage
    }
    
    /**
     파일을 전송하는 함수

     이 함수는 주어진 파일 정보와 대화 상대의 ChatUser 정보를 Firebase에 전송하고, 전송 결과를 반환하는 역할을 합니다.

     - Parameters:
       - fileInfo: 전송할 파일의 정보 (FileInfo)
       - chatUser: 대화 상대의 ChatUser 정보

     - Throws:
       - UserError.currentUserNotFound: 현재 사용자 정보를 찾을 수 없을 경우 에러를 던짐

     - Returns: 전송 결과 메시지
     */
    func sendRecentMessage(text: String, chatUser: ChatUser) async throws -> String {
        guard let currentUser = firebaseService.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let userMessageData = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.profileImageURL: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]

        let recipientRecentMessageData = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.profileImageURL: currentUser.profileImageURL,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.timestamp: firebaseService.timeStamp
        ] as [String : Any]

        let sendMessage = try await firebaseService.sendRecentMessage(
            text: text,
            currentUser: currentUser,
            chatUser: chatUser,
            userMessage: userMessageData,
            recentMessage: recipientRecentMessageData
        )
        
        return sendMessage
    }
}
