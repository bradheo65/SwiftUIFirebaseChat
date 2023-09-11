//
//  RecentMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

protocol StartRecentMessageListenerUseCaseProtocol {
    
    func excute(completion: @escaping (Result<ChatRoom, Error>) -> Void)
    
}

final class StartRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol {
    
    private let chatListenerRepo: ChatListenerRepositoryProtocol
    
    init(chatListenerRepo: ChatListenerRepositoryProtocol) {
        self.chatListenerRepo = chatListenerRepo
    }
    
    /**
     최근 채팅 메시지 리스너를 활성화하고 결과를 반환하는 함수

     이 함수는 최근 채팅 메시지 리스너를 활성화하고, 리스너 실행 결과를 비동기적으로 반환합니다.
     리스너가 성공적으로 실행되면 성공 결과와 최근 채팅 메시지 리스트를 반환하고,
     실행 중 에러가 발생하면 에러 결과와 해당 에러를 반환합니다.

     - Parameters:
       - completion: 리스너 실행 결과를 처리하는 클로저
         - Parameter result: 리스너 실행 결과 (`Result<[ChatRoom], Error>`)
     */
    func excute(completion: @escaping (Result<ChatRoom, Error>) -> Void) {
        chatListenerRepo.startRecentMessageListener { result in
            switch result {
            case .success(let chatRoomList):
                completion(.success(chatRoomList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
