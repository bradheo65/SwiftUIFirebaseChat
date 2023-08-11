//
//  LoginUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginUseCaseProtocol {
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    
}

struct LoginUseCase: LoginUseCaseProtocol {
    private let repo = LoginRepository()
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        repo.requestLogin(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
