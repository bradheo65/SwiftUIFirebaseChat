//
//  SendFileMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol SendFileMessageUseCaseProtocol {
    
    func excute(fileUrl: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class SendFileMessageUseCase: SendFileMessageUseCaseProtocol {
    
    private let sendMessageRepo: SendMessageRepositoryProtocol
    private let uploadFileRepo: UploadFileRepositoryProtocol

    init(sendMessageRepo: SendMessageRepositoryProtocol, uploadFileRepo: UploadFileRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }
    
    func excute(fileUrl: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadFile(url: fileUrl) { result in
            switch result {
            case .success(let fileInfo):
                self.sendMessageRepo.sendFile(fileInfo: fileInfo, chatUser: chatUser) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                        self.sendMessageRepo.sendRecentMessage(text: "파일", chatUser: chatUser) { result in
                            switch result {
                            case .success(let message):
                                completion(.success(message))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
