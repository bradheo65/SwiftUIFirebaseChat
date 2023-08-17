//
//  RecentMessageListenerRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

final class RecentMessageListenerRepository: RecentMessageListenerRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func addRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        firebaseService.addRecentMessageListener { result in
            switch result {
            case .success(let documentChange):
                completion(.success(documentChange))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeRecentMessageListener() {
        firebaseService.removeRecentMessageListener()
    }
    
}
