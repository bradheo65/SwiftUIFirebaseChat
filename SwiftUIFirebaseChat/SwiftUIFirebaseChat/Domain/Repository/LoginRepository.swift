//
//  LoginRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

struct LoginRepository: LoginRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared

    func requestLogin(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseManager.handleLogin(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
