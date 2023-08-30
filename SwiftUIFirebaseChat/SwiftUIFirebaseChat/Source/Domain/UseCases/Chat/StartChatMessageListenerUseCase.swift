//
//  StartChatMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol StartChatMessageListenerUseCaseProtocol {
    
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatLog, Error>) -> Void)
    
}

final class StartChatMessageListenerUseCase: StartChatMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    /**
     대상 채팅 사용자의 채팅 메시지 리스너를 활성화하고 결과를 비동기적으로 반환하는 함수

     이 함수는 주어진 대상 채팅 사용자 정보를 사용하여 해당 사용자의 채팅 메시지 리스너를 활성화하고, 비동기적으로 실행 결과를 처리합니다.
     리스너가 성공적으로 실행되면 성공 결과와 받아온 채팅 메시지를 클로저를 통해 전달하고,
     실행 중 에러가 발생하면 에러 결과와 해당 에러를 클로저를 통해 전달합니다.

     - Parameters:
       - chatUser: 대상 채팅 사용자 정보
       - completion: 리스너 실행 결과를 처리하는 클로저
         - Parameter result: 리스너 실행 결과 (`Result<ChatMessage, Error>`)
     */
    func excute(chatUser: ChatUser, completion: @escaping (Result<ChatLog, Error>) -> Void) {
        chatListenerRepo.startChatMessageListener(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                completion(.success(chatMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
