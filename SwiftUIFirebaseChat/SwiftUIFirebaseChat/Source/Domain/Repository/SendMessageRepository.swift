//
//  SendMessageRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI
import AVFoundation

final class SendMessageRepository: SendMessageRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func thumbnailImageForVideoURL(fileURL: URL) -> UIImage? {
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func sendText(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.sendTextMessage(text: text, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendImage(url: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.sendImageMessage(imageURL: url, image: image, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendVideo(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.sendVideoMessage(imageUrl: imageUrl, videoUrl: videoUrl, image: image, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendFile(fileInfo: FileInfo, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.sendFileMessage(fileInfo: fileInfo, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendRecentMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.sendRecentMessage(text: text, chatUser: chatUser) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
