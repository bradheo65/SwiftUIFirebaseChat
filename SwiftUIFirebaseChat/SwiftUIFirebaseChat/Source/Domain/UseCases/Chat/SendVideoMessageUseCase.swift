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

final class SendVideoMessageUseCase: SendVideoMessageUseCaseProtocol {
    
    private let sendMessageRepo: SendMessageRepositoryProtocol
    private let uploadFileRepo: FileUploadRepositoryProtocol
    
    init(sendMessageRepo: SendMessageRepositoryProtocol, uploadFileRepo: FileUploadRepositoryProtocol) {
        self.sendMessageRepo = sendMessageRepo
        self.uploadFileRepo = uploadFileRepo
    }

    func excute(url: URL, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        uploadFileRepo.uploadVideo(url: url) { result in
            switch result {
            case .success(let url):
                if let thumbnailImage = self.sendMessageRepo.thumbnailImageForVideoURL(fileURL: url) {
                    self.uploadFileRepo.uploadImage(image: thumbnailImage) { result in
                        switch result {
                        case .success(let thumbnailUrl):
                            self.sendMessageRepo.sendVideo(imageUrl: thumbnailUrl, videoUrl: url, image: thumbnailImage, chatUser: chatUser) { result in
                                switch result {
                                case .success(let message):
                                    completion(.success(message))
                                    self.sendMessageRepo.sendRecentMessage(text: "비디오", chatUser: chatUser) { result in
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
