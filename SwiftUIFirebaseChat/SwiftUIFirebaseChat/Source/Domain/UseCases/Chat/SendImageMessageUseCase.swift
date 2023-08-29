//
//  SendImageMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

protocol SendImageMessageUseCaseProtocol {
    
    func excute(image: UIImage, chatUser: ChatUser) async throws -> String
    
}

final class SendImageMessageUseCase: SendImageMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    private let uploadFileRepo: FileUploadRepositoryProtocol
    
    init(sendMessageRepo: MessagingRepositoryProtocol, uploadFileRepo: FileUploadRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }
    
    /**
     이미지를 전송하고 최근 메시지를 업데이트하는 함수

     이 함수는 주어진 이미지와 대상 채팅 사용자를 사용하여 이미지를 전송하고, 최근 메시지를 업데이트하는 역할을 합니다.
     이미지 업로드, 메시지 전송 및 최근 메시지 업데이트 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - image: 전송할 이미지
       - chatUser: 대상 채팅 사용자 정보

     - Throws:
       - 기타 에러: 이미지 업로드, 메시지 전송 및 최근 메시지 업데이트 과정에서 발생한 에러를 전달

     - Returns: 이미지 전송 및 최근 메시지 업데이트 결과 메시지
     */
    func excute(image: UIImage, chatUser: ChatUser) async throws -> String {
        // 이미지를 업로드하고 업로드 결과 URL을 받아옵니다.
        let uploadImageResult = try await uploadFileRepo.uploadImage(image: image)
        
        // 이미지를 전송하고 결과를 무시합니다.
        let (_) = try await sendMessageRepo.sendImage(
            url: uploadImageResult,
            image: image,
            chatUser: chatUser
        )
        
        // 최근 메시지를 업데이트하고 결과 메시지를 받아옵니다.
        let sendRecentMessage = try await sendMessageRepo.sendRecentMessage(
            text: "이미지",
            chatUser: chatUser
        )
        
        return sendRecentMessage
    }
    
}
