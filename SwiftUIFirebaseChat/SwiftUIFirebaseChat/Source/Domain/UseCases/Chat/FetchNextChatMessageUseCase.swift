//
//  FetchNextChatMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/14.
//

import Foundation

protocol FetchNextChatMessageUseCaseProtocol {
    
    func excute(from date: Date?, chatRoomID: String, completion: @escaping (ChatLog) -> Void)
    
}

final class FetchNextChatMessageUseCase: FetchNextChatMessageUseCaseProtocol {
    private let messageRepo: MessagingRepositoryProtocol

    init(messageRepo: MessagingRepositoryProtocol) {
        self.messageRepo = messageRepo
    }
    
    func excute(from date: Date?, chatRoomID: String, completion: @escaping (ChatLog) -> Void) {
        messageRepo.fetchNextChatMessage(from: date, chatRoomID: chatRoomID) { chatLog in
            completion(chatLog)
        }
    }
}
