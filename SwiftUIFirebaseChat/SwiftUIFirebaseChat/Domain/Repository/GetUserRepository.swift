//
//  GetUserRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

final class GetUserRepository: GetUserRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func requestAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        firebaseService.getAllUsers { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        firebaseService.getCurrentUser { result in
            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
