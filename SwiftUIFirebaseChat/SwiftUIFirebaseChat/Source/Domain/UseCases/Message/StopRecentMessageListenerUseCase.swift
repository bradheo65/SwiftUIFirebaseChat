//
//  StopRecentMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol StopRecentMessageListenerUseCaseProtocol {
    
    func excute()
    
}

final class StopRecentMessageListenerUseCase: StopRecentMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute() {
        chatListenerRepo.stopRecentMessageListener()
    }
    
}
