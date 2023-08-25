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
    
    func excute(image: UIImage, chatUser: ChatUser) async throws -> String {
        let uploadImageResult = try await uploadFileRepo.uploadImage(image: image)
        let (_) = try await sendMessageRepo.sendImage(url: uploadImageResult, image: image, chatUser: chatUser)
        let sendRecentMessage = try await sendMessageRepo.sendRecentMessage(text: "이미지", chatUser: chatUser)
        
        return sendRecentMessage
    }
    
}
