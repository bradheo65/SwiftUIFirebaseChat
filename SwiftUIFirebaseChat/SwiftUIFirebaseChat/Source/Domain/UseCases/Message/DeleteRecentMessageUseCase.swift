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
    
    private let repo: DeleteMessageRepositoryProtocol
    
    init(repo: DeleteMessageRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        repo.deleteRecentChatMessage(toId: toId) { result in
            switch result {
            case .success(_):
                self.repo.deleteChatMessage(toId: toId) { result in
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
