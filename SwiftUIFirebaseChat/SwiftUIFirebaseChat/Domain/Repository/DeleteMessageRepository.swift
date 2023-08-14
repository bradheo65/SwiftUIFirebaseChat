//
//  DeleteMessageRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

struct DeleteMessageRepository: DeleteMessageRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared
    
    func deleteChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseManager.deleteChatMessage(toId: toId) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteRecentChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseManager.deleteRecentMessage(toId: toId) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
