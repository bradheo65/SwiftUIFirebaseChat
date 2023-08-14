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

struct DeleteRecentMessageUseCase {
    
    private let repo = DeleteMessageRepository()
    
    func excute(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        repo.deleteRecentChatMessage(toId: toId) { result in
            switch result {
            case .success(let message):
                repo.deleteChatMessage(toId: toId) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    completion(.success(message))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
