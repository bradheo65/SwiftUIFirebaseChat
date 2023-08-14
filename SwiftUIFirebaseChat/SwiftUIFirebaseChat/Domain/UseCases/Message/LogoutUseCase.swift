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

struct LogoutUseCase: LogoutUseCaseProtocol {
    
    private let repo = LogoutRepository()
    
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
