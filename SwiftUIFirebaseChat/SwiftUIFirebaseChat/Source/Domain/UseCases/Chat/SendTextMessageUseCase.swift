//
//  SendTextMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol SendTextMessageUseCaseProtocol {
    
    func execute(text: String, chatUser: ChatUser) async throws -> String
    
}

final class SendTextMessageUseCase: SendTextMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    
    init(sendMessageRepo: MessagingRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
    }
    
    /**
     텍스트 메시지를 전송하고 최근 메시지도 업데이트하는 함수

     이 함수는 주어진 텍스트 메시지와 대상 채팅 사용자를 사용하여 텍스트 메시지를 전송하고, 최근 메시지를 업데이트하는 역할을 합니다.
     메시지 전송 및 최근 메시지 업데이트 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - text: 전송할 텍스트 메시지
       - chatUser: 대상 채팅 사용자 정보

     - Throws:
       - 기타 에러: 메시지 전송 및 최근 메시지 업데이트 과정에서 발생한 에러를 전달

     - Returns: 메시지 전송 및 최근 메시지 업데이트 결과 메시지
     */
    func execute(text: String, chatUser: ChatUser) async throws -> String {
        let (_) = try await sendMessageRepo.sendText(
            text: text,
            chatUser: chatUser
        )
        let sendRecentMessageResult = try await sendMessageRepo.sendRecentMessage(
            text: text,
            chatUser: chatUser
        )
        
        return sendRecentMessageResult
    }
    
}
