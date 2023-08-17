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

final class LoginUseCase: LoginUseCaseProtocol {
    
    private let repo: LoginRepositoryProtocol
    
    init(repo: LoginRepositoryProtocol) {
        self.repo = repo
    }
    
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
