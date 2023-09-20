//
//  FetchAllChatMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/18.
//

import Foundation

protocol FetchAllChatMessageUseCaseProtocol {
    
    func excute(chatUser: [ChatUser]) async throws
    
}

final class FetchAllChatMessageUseCase: FetchAllChatMessageUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute(chatUser: [ChatUser]) async throws {
        try await chatUser.asyncForEach { user in
            try await self.chatListenerRepo.fetchUserChatMessage(chatUser: user)
        }
    }
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
