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

final class SendImageMessageUseCase: SendImageMessageUseCaseProtocol {
    
    private let sendMessageRepo: SendMessageRepositoryProtocol
    private let uploadFileRepo: UploadFileRepositoryProtocol
    
    init(sendMessageRepo: SendMessageRepositoryProtocol, uploadFileRepo: UploadFileRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }
    
    func excute(image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadImage(image: image) { result in
            switch result {
            case .success(let url):
                self.sendMessageRepo.sendImage(url: url, image: image, chatUser: chatUser) { result in
                    switch result {
                    case .success(let message):
                        completion(.success(message))
                        self.sendMessageRepo.sendRecentMessage(text: "이미지", chatUser: chatUser) { result in
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
