//
//  GetAllUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/11.
//

import Foundation

protocol GetAllUserUseCaseProtocol {
    
    func excute(completion: @escaping (Result<ChatUser, Error>) -> Void)
    
}

final class GetAllUserUseCase: GetAllUserUseCaseProtocol {
    
    private let repo: GetUserRepositoryProtocol
    
    init(repo: GetUserRepositoryProtocol) {
        self.repo = repo
    }
    
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
