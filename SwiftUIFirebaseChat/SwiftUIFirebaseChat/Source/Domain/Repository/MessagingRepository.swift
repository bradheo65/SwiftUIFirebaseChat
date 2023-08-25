//
//  MessagingRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI
import AVFoundation

final class MessagingRepository: MessagingRepositoryProtocol {
 
    private let firebaseService: FirebaseMessagingServiceProtocol
    
    init(firebaseService: FirebaseMessagingServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
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
        
        let sendMessage = try await firebaseService.sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData)
        
        return sendMessage
    }
    
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
        
        let sendMessage = try await firebaseService.sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData)
        
        return sendMessage
    }
    
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
        
        let sendMessage = try await firebaseService.sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData)
        
        return sendMessage
    }
    
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
        
        let sendMessage = try await firebaseService.sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData)
        
        return sendMessage
    }
    
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

        let sendMessage = try await firebaseService.sendRecentMessage(text: text, currentUser: currentUser, chatUser: chatUser, userMessage: userMessageData, recentMessage: recipientRecentMessageData)
        
        return sendMessage
    }
    
}
