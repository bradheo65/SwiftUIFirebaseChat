//
//  StopChatMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol StopChatMessageListenerUseCaseProtocol {
    
    func excute()
    
}

final class StopChatMessageListenerUseCase: StopChatMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute() {
        chatListenerRepo.stopChatMessageListener()
    }
    
}
