//
//  SendTextMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol SendTextMessageUseCaseProtocol {
    
    func excute(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class SendTextMessageUseCase: SendTextMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    
    init(sendMessageRepo: MessagingRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
    }
    
    func excute(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        sendMessageRepo.sendText(text: text, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
                self.sendMessageRepo.sendRecentMessage(text: text, chatUser: chatUser) { result in
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
