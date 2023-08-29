//
//  SendFileMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol SendFileMessageUseCaseProtocol {
    
    func excute(url: URL, chatUser: ChatUser) async throws -> String
    
}

final class SendFileMessageUseCase: SendFileMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    private let uploadFileRepo: FileUploadRepositoryProtocol

    init(sendMessageRepo: MessagingRepositoryProtocol, uploadFileRepo: FileUploadRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }
    
    /**
     파일을 전송하고 최근 메시지를 업데이트하는 함수

     이 함수는 주어진 파일 URL과 대상 채팅 사용자를 사용하여 파일을 전송하고, 최근 메시지를 업데이트하는 역할을 합니다.
     파일 업로드, 메시지 전송 및 최근 메시지 업데이트 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - url: 전송할 파일의 파일 URL
       - chatUser: 대상 채팅 사용자 정보

     - Throws:
       - 기타 에러: 파일 업로드, 메시지 전송 및 최근 메시지 업데이트 과정에서 발생한 에러를 전달

     - Returns: 파일 전송 및 최근 메시지 업데이트 결과 메시지
     */
    func excute(url: URL, chatUser: ChatUser) async throws -> String {
        // 파일을 업로드하고 업로드 결과 정보를 받아옵니다.
        let uploadFileInfo = try await uploadFileRepo.uploadFile(url: url)
        
        // 파일을 전송하고 결과를 무시합니다.
        let (_) = try await sendMessageRepo.sendFile(
            fileInfo: uploadFileInfo,
            chatUser: chatUser
        )
        
        // 최근 메시지를 업데이트하고 결과 메시지를 받아옵니다.
        let sendRecentMessageResult = try await sendMessageRepo.sendRecentMessage(
            text: "파일",
            chatUser: chatUser
        )
        
        return sendRecentMessageResult
    }
    
}
