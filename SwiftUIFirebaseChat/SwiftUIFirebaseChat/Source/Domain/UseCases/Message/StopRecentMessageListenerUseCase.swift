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
    
    /**
     최근 채팅 메시지 리스너를 중지하는 함수

     이 함수는 현재 활성화되어 있는 최근 채팅 메시지 리스너를 중지하는 역할을 합니다.
     리스너가 중지되면 더 이상 새로운 메시지를 받아오지 않습니다.
     */
    func excute() {
        chatListenerRepo.stopRecentMessageListener()
    }
    
}
