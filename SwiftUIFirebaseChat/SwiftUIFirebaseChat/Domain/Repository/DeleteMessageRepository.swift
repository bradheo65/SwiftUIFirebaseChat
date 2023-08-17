//
//  DeleteMessageRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

final class DeleteMessageRepository: DeleteMessageRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func deleteChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.deleteChatMessage(toId: toId) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteRecentChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.deleteRecentMessage(toId: toId) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
