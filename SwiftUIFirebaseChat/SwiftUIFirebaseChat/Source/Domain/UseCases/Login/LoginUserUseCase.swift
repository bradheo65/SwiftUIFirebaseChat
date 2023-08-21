//
//  LoginUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginUserUseCaseProtocol {
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class LoginUserUseCase: LoginUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        userRepo.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
