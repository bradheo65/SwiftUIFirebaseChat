//
//  MockFirebaseService.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/17.
//

import Foundation
import SwiftUI

import Firebase

@testable import SwiftUIFirebaseChat

final class MockFirebaseService {
    
    var mockError: Error?
    var mockAllUsersResult: Result<ChatUser, Error>?
    var mockCurrentUserResult: Result<ChatUser?, Error>?
    var mockUrlResult: Result<URL, Error>?
    var mockFireInfoResult: Result<FileInfo, Error>?
    var mockChatMessageResult: Result<ChatMessage, Error>?

}

extension MockFirebaseService: FirebaseUserServiceProtocol {
    
    func registerUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Register User"))
        }
    }
    
    func saveUserInfo(email: String, profileImageUrl: URL, store: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Save User Info"))
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Login"))
        }
    }
    
    func logoutUser(completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Logout"))
        }
    }
    
    func fetchAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        if let result = mockAllUsersResult {
            completion(result)
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        if let result = mockCurrentUserResult {
            completion(result)
        }
    }
    
}

extension MockFirebaseService: FirebaseFileUploadServiceProtocol {
    
    func uploadImage(image: UIImage, store: String, compltion: @escaping (Result<URL, Error>) -> Void) {
        if let result = mockUrlResult {
            compltion(result)
        }
    }
    
    func uploadVideo(url: URL, store: String, compltion: @escaping (Result<URL, Error>) -> Void) {
        if let result = mockUrlResult {
            compltion(result)
        }
    }
    
    func uploadFile(url: URL, store: String, compltion: @escaping (Result<FileInfo, Error>) -> Void) {
        if let result = mockFireInfoResult {
            compltion(result)
        }
    }
    
}

extension MockFirebaseService: FirebaseMessagingServiceProtocol {
    
    func sendTextMessage(text: String, chatUser: SwiftUIFirebaseChat.ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send Text Message"))
        }
    }
    
    func sendImageMessage(imageURL: URL, image: UIImage, chatUser: SwiftUIFirebaseChat.ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send Image Message"))
        }
    }
    
    func sendVideoMessage(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: SwiftUIFirebaseChat.ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send Video Message"))
        }
    }
    
    func sendFileMessage(fileInfo: SwiftUIFirebaseChat.FileInfo, chatUser: SwiftUIFirebaseChat.ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send File Message"))
        }
    }
    
    func sendRecentMessage(text: String, chatUser: SwiftUIFirebaseChat.ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send Recent Message"))
        }
    }
    
    func sendMessage(fromId: String, toId: String, messageData: [String : Any], completion: @escaping (Result<String, Error>) -> Void) {
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success("Success to Send Message"))
        }
    }
    
}

extension MockFirebaseService: FirebaseChatListenerProtocol {
    func listenForChatMessage(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        if let result = mockChatMessageResult {
            completion(result)
        }
    }
    
    func stopListenForChatMessage() {
        // no test
    }
    
    func listenForRecentMessage(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        // no test
    }
    
    func stopListenForRecentMessage() {
        // no test
    }
    
}
