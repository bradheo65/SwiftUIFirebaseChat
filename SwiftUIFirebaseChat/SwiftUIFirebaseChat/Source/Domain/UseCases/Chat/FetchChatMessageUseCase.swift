//
//  FetchChatMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/14.
//

import Foundation

protocol FetchChatMessageUseCaseProtocol {
    
    func excute(chatRoomID: String, completion: @escaping (ChatLog) -> Void)
    
}

final class FetchChatMessageUseCase: FetchChatMessageUseCaseProtocol {
    private let messageRepo: MessagingRepositoryProtocol

    init(messageRepo: MessagingRepositoryProtocol) {
        self.messageRepo = messageRepo
    }
    
    func excute(chatRoomID: String, completion: @escaping (ChatLog) -> Void) {
        messageRepo.fetchChatMessage(chatRoomID: chatRoomID) { chatLog in
            completion(chatLog)
        }
    }
}
