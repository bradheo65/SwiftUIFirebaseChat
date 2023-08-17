//
//  RemoveChatMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol RemoveChatMessageListenerUseCaseProtocol {
    
    func excute()
    
}

final class RemoveChatMessageListenerUseCase: RemoveChatMessageListenerUseCaseProtocol {
    
    private let chatMessageListenerRepo: ChatMessageListenerRepositoryProtocol
    
    init(chatMessageListenerRepo: ChatMessageListenerRepositoryProtocol) {
        self.chatMessageListenerRepo = chatMessageListenerRepo
    }
    
    func excute() {
        chatMessageListenerRepo.removeChatMessageListener()
    }
    
}
