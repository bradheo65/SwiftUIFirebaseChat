//
//  SendImageMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

protocol SendImageMessageUseCaseProtocol {
    
    func excute(image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    
}

struct SendImageMessageUseCase: SendImageMessageUseCaseProtocol {
    
    private let sendMessageRepo = SendMessageRepository()
    private let uploadFileRepo = UploadFileRepository()
    
    func excute(image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadImage(image: image) { result in
            switch result {
            case .success(let url):
                sendMessageRepo.sendImage(url: url, image: image, chatUser: chatUser) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                        sendMessageRepo.sendRecentMessage(text: "이미지", chatUser: chatUser) { result in
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
