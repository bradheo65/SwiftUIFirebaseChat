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
    
    func excute(url: URL, chatUser: ChatUser) async throws -> String {
        let videoUrl = try await uploadFileRepo.uploadVideo(url: url)
        let thumbnailImage = try ThumbnailUtilities.generateThumbnailForVideo(fileURL: url)
        let thumbnailImageUrl = try await uploadFileRepo.uploadImage(image: thumbnailImage)
        let (_) = try await sendMessageRepo.sendVideo(imageUrl: thumbnailImageUrl, videoUrl: videoUrl, image: thumbnailImage, chatUser: chatUser)
        let recentMessage = try await sendMessageRepo.sendRecentMessage(text: "비디오", chatUser: chatUser)
        
        return recentMessage
    }
    
}
