//
//  LogoutRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

struct LogoutRepository: LogoutRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared

    func requestLogout(completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.handleLogout() { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
