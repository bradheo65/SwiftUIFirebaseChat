//
//  RecentMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

protocol StartRecentMessageListenerUseCaseProtocol {
    
    func excute(completion: @escaping (Result<[RecentMessage], Error>) -> Void)
    
}

final class StartRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute(completion: @escaping (Result<[RecentMessage], Error>) -> Void) {
        chatListenerRepo.startRecentMessageListener { result in
            switch result {
            case .success(let documentChange):
                completion(.success(documentChange))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
