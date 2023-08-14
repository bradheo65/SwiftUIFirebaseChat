//
//  RecentMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

protocol ActiveRecentMessageListenerUseCaseProtocol {
    
    func excute(completion: @escaping (Result<DocumentChange, Error>) -> Void)
    
}

struct ActiveRecentMessageListenerUseCase: ActiveRecentMessageListenerUseCaseProtocol {
    
    private let repo = RecentMessageListenerRepository()
    
    func excute(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        repo.activeRecentMessageListener { result in
            switch result {
            case .success(let documentChange):
                completion(.success(documentChange))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
