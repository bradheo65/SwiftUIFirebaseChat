//
//  MockUserRepository.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/18.
//

import Foundation

@testable import SwiftUIFirebaseChat

final class MockUserRepository: UserRepositoryProtocol {
    
    private var firebaseUserService: FirebaseUserServiceProtocol
    
    init(firebaseUserService: FirebaseUserServiceProtocol) {
        self.firebaseUserService = firebaseUserService
    }

    func registerUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseUserService.registerUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveUserInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseUserService.saveUserInfo(email: email, profileImageUrl: profileImageUrl, store: "mockStore") { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseUserService.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logoutUser(completion: @escaping (Result<String, Error>) -> Void) {
        firebaseUserService.logoutUser() { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        firebaseUserService.fetchAllUser { result in
            switch result {
            case .success(let chatUser):
                completion(.success(chatUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        firebaseUserService.fetchCurrentUser { result in
            switch result {
            case .success(let chatUser):
                completion(.success(chatUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
