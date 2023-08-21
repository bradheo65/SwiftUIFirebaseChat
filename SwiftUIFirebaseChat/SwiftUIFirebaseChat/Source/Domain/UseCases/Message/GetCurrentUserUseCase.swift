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

final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        userRepo.fetchCurrentUser { result in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
