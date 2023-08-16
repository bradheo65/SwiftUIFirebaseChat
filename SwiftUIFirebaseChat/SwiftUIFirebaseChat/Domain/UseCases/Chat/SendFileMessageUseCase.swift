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

struct SendFileMessageUseCase: SendFileMessageUseCaseProtocol {
    
    private let sendMessageRepo = SendMessageRepository()
    private let uploadFileRepo = UploadFileRepository()

    func excute(fileUrl: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadFile(url: fileUrl) { result in
            switch result {
            case .success(let fileInfo):
                sendMessageRepo.sendFile(fileInfo: fileInfo, chatUser: chatUser) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                        sendMessageRepo.sendRecentMessage(text: "파일", chatUser: chatUser) { result in
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
