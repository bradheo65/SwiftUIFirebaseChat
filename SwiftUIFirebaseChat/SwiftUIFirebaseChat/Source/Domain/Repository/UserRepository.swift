//
//  UserRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

final class UserRepository: UserRepositoryProtocol {
    
    private let firebaseService: FirebaseUserServiceProtocol
    
    init(firebaseService: FirebaseUserServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func registerUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.registerUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveUserInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.saveUserInfo(email: email, profileImageUrl: profileImageUrl, store: FirebaseConstants.users) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logoutUser(completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.logoutUser { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        firebaseService.fetchAllUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        firebaseService.fetchCurrentUser { result in
            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}


