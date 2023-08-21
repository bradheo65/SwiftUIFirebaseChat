//
//  MockFirebaseService.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/17.
//

import Foundation
import SwiftUI

@testable import SwiftUIFirebaseChat

final class MockFirebaseService {
    
    var mockError: Error?
    var mockAllUsersResult: Result<ChatUser, Error>?
    var mockCurrentUserResult: Result<ChatUser?, Error>?
    var mockUrlResult: Result<URL, Error>?
    var mockFireInfoResult: Result<FileInfo, Error>?

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
