//
//  RecentMessageListenerRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

struct RecentMessageListenerRepository: RecentMessageListenerRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared
    
    func activeRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        firebaseManager.handleRecentMessageListener { result in
            switch result {
            case .success(let documentChange):
                completion(.success(documentChange))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeRecentMessageListener() {
        firebaseManager.handleRemoveRecentMessageListener()
    }
    
}
