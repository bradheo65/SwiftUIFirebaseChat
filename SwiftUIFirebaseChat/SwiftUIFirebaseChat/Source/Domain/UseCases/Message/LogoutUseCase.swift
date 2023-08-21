//
//  LogoutUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol LogoutUseCaseProtocol {
    
    func excute(completion: @escaping ((Result<String, Error>) -> Void))
    
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute(completion: @escaping ((Result<String, Error>) -> Void)) {
        userRepo.logoutUser { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
