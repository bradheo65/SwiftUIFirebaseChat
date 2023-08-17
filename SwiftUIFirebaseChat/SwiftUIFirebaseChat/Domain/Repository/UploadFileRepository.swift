//
//  UploadFileRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

protocol UploadFileRepositoryProtocol {
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
    func uploadFile(url: URL, compltion: @escaping (Result<FileInfo, Error>) -> Void)
    
}

final class UploadFileRepository: UploadFileRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        firebaseService.uploadImage(image: image, store: FirebaseConstants.Storage.messageImages) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        firebaseService.uploadVideo(url: url, store: FirebaseConstants.Storage.messageVideos) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func uploadFile(url: URL, compltion: @escaping (Result<FileInfo, Error>) -> Void) {
        firebaseService.uploadFile(url: url, store: FirebaseConstants.Storage.messageFiles) { result in
            switch result {
            case .success(let fileInfo):
                compltion(.success(fileInfo))
            case .failure(let error):
                compltion(.failure(error))
            }
        }
    }
    
}
