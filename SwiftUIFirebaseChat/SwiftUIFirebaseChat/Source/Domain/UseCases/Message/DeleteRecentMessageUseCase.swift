//
//  DeleteRecentMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol DeleteRecentMessageUseCaseProtocol {
    
    func excute(toId: String, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class DeleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        userRepo.deleteRecentChatMessage(toId: toId) { result in
            switch result {
            case .success(_):
                self.userRepo.deleteChatMessage(toId: toId) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
