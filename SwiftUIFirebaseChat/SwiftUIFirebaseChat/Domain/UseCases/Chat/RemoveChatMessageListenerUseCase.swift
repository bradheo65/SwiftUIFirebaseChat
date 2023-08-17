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

struct RemoveChatMessageListenerUseCase: RemoveChatMessageListenerUseCaseProtocol {
    
    private let chatMessageListenerRepo = ChatMessageListenerRepository()
    
    init() {
        
    }
    
    func excute() {
        chatMessageListenerRepo.removeChatMessageListener()
    }
    
}
