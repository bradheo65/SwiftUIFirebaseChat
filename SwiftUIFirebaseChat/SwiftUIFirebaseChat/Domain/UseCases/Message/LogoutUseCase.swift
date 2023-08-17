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
    
    private let repo: LogoutRepositoryProtocol
    
    init(repo: LogoutRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute(completion: @escaping ((Result<String, Error>) -> Void)) {
        repo.requestLogout { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
