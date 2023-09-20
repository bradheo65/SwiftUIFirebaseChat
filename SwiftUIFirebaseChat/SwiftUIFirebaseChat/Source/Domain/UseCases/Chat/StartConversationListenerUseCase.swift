//
//  StartConversationListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

protocol StartConversationListenerUseCaseProtocol {
    
    func excute(chatUserUID: String?, completion: @escaping (String) -> Void)
    
}

final class StartConversationListenerUseCase: StartConversationListenerUseCaseProtocol {
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    func excute(chatUserUID: String?, completion: @escaping (String) -> Void) {
        chatListenerRepo.checkChatUserUID(chatUserUID: chatUserUID) { id in
            completion(id)
        }
        chatListenerRepo.startRealmConversationListener(chatUserUID: chatUserUID) { id in
            completion(id)
        }
    }
}
