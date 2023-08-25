//
//  SendTextMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol SendTextMessageUseCaseProtocol {
    
    func execute(text: String, chatUser: ChatUser) async throws -> String
    
}

final class SendTextMessageUseCase: SendTextMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    
    init(sendMessageRepo: MessagingRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
    }
    
    func execute(text: String, chatUser: ChatUser) async throws -> String {
        let (_) = try await sendMessageRepo.sendText(text: text, chatUser: chatUser)
        let sendRecentMessageResult = try await sendMessageRepo.sendRecentMessage(text: text, chatUser: chatUser)
        
        return sendRecentMessageResult
    }
    
}
