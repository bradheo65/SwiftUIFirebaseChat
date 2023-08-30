//
//  SendVideoMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol SendVideoMessageUseCaseProtocol {
    
    func excute(url: URL, chatUser: ChatUser) async throws -> String
    
}

final class SendVideoMessageUseCase: SendVideoMessageUseCaseProtocol {
    
    private let sendMessageRepo: MessagingRepositoryProtocol
    private let uploadFileRepo: FileUploadRepositoryProtocol
    
    init(sendMessageRepo: MessagingRepositoryProtocol, uploadFileRepo: FileUploadRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }
    
    /**
     비디오를 전송하고 최근 메시지를 업데이트하는 함수

     이 함수는 주어진 비디오 URL과 대상 채팅 사용자를 사용하여 비디오를 전송하고, 최근 메시지를 업데이트하는 역할을 합니다.
     비디오 업로드, 썸네일 이미지 생성 및 업로드, 메시지 전송 및 최근 메시지 업데이트 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - url: 전송할 비디오의 파일 URL
       - chatUser: 대상 채팅 사용자 정보

     - Throws:
       - 기타 에러: 비디오 업로드, 썸네일 이미지 업로드, 메시지 전송 및 최근 메시지 업데이트 과정에서 발생한 에러를 전달

     - Returns: 비디오 전송 및 최근 메시지 업데이트 결과 메시지
     */
    func excute(url: URL, chatUser: ChatUser) async throws -> String {
        // 비디오를 업로드하고 업로드 결과 URL을 받아옵니다.
        let videoUrl = try await uploadFileRepo.uploadVideo(url: url)
        
        // 비디오 파일에서 썸네일 이미지를 생성합니다.
        let thumbnailImage = try ThumbnailUtilities.generateThumbnailForVideo(fileURL: url)
        
        // 썸네일 이미지를 업로드하고 업로드 결과 URL을 받아옵니다.
        let thumbnailImageUrl = try await uploadFileRepo.uploadImage(image: thumbnailImage)
        
        // 최근 메시지를 업데이트하고 결과 메시지를 받아옵니다.
        let recentMessage = try await sendMessageRepo.sendRecentMessage(
            text: "비디오",
            chatUser: chatUser
        )
        
        // 비디오와 썸네일 이미지를 전송하고 결과를 무시합니다.
        let (_) = try await sendMessageRepo.sendVideo(
            imageUrl: thumbnailImageUrl,
            videoUrl: videoUrl,
            image: thumbnailImage,
            chatUser: chatUser
        )
        
        return recentMessage
    }
    
}
