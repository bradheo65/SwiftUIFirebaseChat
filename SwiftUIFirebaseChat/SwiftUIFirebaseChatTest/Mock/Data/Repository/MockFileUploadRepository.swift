//
//  MockFileUploadRepository.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/18.
//

import Foundation
import SwiftUI

@testable import SwiftUIFirebaseChat

final class MockFileUploadRepository: FileUploadRepositoryProtocol {
    
    private var firebaseFileUploadService: FirebaseFileUploadServiceProtocol
    
    init(firebaseFileUploadService: FirebaseFileUploadServiceProtocol) {
        self.firebaseFileUploadService = firebaseFileUploadService
    }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        firebaseFileUploadService.uploadImage(image: image, store: "mockStore") { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        firebaseFileUploadService.uploadVideo(url: url, store: "mockStore") { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadFile(url: URL, compltion: @escaping (Result<FileInfo, Error>) -> Void) {
        firebaseFileUploadService.uploadFile(url: url, store: "mockStore") { result in
            switch result {
            case .success(let fireInfo):
                compltion(.success(fireInfo))
            case .failure(let error):
                compltion(.failure(error))
            }
        }
    }
    
}
