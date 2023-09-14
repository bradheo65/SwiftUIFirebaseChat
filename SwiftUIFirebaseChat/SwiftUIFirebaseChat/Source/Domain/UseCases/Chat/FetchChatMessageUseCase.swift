//
//  FetchChatMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/14.
//

import Foundation

protocol FetchChatMessageUseCaseProtocol {
    func excute(chatUser: ChatUser, completion: @escaping (ChatLog) -> Void)
}

final class FetchChatMessageUseCase: FetchChatMessageUseCaseProtocol {
    
    private let messageRepo: MessagingRepositoryProtocol

    init(messageRepo: MessagingRepositoryProtocol) {
        self.messageRepo = messageRepo
    }
    
    func excute(chatUser: ChatUser, completion: @escaping (ChatLog) -> Void) {
        messageRepo.fetchChatMessage(chatUser: chatUser) { chatLog in
            completion(chatLog)
        }
    }
    
}
