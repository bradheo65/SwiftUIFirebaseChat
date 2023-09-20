//
//  FetchUserChatMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

protocol FetchUserChatMessageUseCaseProtocol {
    
    func excute(chatUser: ChatUser) async throws
    
}

final class FetchUserChatMessageUseCase: FetchUserChatMessageUseCaseProtocol {
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute(chatUser: ChatUser) async throws {
        return try await chatListenerRepo.fetchUserChatMessage(chatUser: chatUser)
    }
}
