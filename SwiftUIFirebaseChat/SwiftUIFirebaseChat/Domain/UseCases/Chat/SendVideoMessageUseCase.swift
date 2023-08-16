//
//  SendVideoMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation

protocol SendVideoMessageUseCaseProtocol {
    
    func excute(url: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    
}

struct SendVideoMessageUseCase: SendVideoMessageUseCaseProtocol {
    
    private let sendMessageRepo = SendMessageRepository()
    private let uploadFileRepo = UploadFileRepository()

    func excute(url: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadVideo(url: url) { result in
            switch result {
            case .success(let url):
                if let thumbnailImage = sendMessageRepo.thumbnailImageForVideoURL(fileURL: url) {
                    uploadFileRepo.uploadImage(image: thumbnailImage) { result in
                        switch result {
                        case .success(let thumbnailUrl):
                            sendMessageRepo.sendVideo(imageUrl: thumbnailUrl, videoUrl: url, image: thumbnailImage, chatUser: chatUser) { result in
                                switch result {
                                case .success(let message):
                                    completion(.success(message))
                                    sendMessageRepo.sendRecentMessage(text: "비디오", chatUser: chatUser) { result in
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
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
