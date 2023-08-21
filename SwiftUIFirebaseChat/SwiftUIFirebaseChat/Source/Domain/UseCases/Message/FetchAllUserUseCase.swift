//
//  FetchAllUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/11.
//

import Foundation

protocol FetchAllUserUseCaseProtocol {
    
    func excute(completion: @escaping (Result<ChatUser, Error>) -> Void)
    
}

final class FetchAllUserUseCase: FetchAllUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        userRepo.fetchAllUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
