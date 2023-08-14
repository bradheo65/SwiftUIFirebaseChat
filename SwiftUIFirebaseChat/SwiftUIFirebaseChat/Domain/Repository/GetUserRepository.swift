//
//  GetUserRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

struct GetUserRepository: GetUserRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared
    
    func requestAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        firebaseManager.getAllUsers { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        firebaseManager.getCurrentUser { result in
            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
