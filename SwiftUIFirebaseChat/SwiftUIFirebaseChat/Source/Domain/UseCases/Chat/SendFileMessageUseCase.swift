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
    
    func excute(url: URL, chatUser: ChatUser) async throws -> String {
        let uploadFileInfo = try await uploadFileRepo.uploadFile(url: url)
        
        let (_) = try await sendMessageRepo.sendFile(fileInfo: uploadFileInfo, chatUser: chatUser)
        let sendRecentMessageResult = try await sendMessageRepo.sendRecentMessage(text: "파일", chatUser: chatUser)
        
        return sendRecentMessageResult
    }
    
}
