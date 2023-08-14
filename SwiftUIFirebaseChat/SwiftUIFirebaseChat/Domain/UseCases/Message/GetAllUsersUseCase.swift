//
//  GetAllUsersUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/11.
//

import Foundation

protocol GetAllUsersUseCaseProtocol {
    
    func excute(completion: @escaping (Result<ChatUser, Error>) -> Void)
    
}

struct GetAllUsersUseCase: GetAllUsersUseCaseProtocol {
    
    private let repo = GetUserRepository()
    
    func excute(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        repo.requestAllUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}