//
//  LoginAccountUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginAccountUseCaseProtocol {
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    
}

struct LoginAccountUseCase: LoginAccountUseCaseProtocol {
    private let repo = LoginAccountRepository()
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        repo.requestLoginUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
