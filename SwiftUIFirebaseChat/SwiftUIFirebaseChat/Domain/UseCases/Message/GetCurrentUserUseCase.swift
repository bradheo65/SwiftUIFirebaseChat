//
//  GetCurrentUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol GetCurrentUserUseCaseProtocol {
    
    func excute(completion: @escaping (Result<ChatUser?, Error>) -> Void)
    
}

struct GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
    
    private let repo = GetUserRepository()
    
    func excute(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        repo.requestCurrentUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
