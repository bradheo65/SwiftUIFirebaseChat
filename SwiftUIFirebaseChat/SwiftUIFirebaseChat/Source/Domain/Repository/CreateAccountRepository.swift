//
//  CreateAccountRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

final class CreateAccountRepository: CreateAccountRepositoryProtocol {
    
    private let firebaseService = FirebaseService.shared
    
    func requestCreateAccount(email: String, password: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.handleCreateAccount(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestUploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        firebaseService.uploadImage(image: image, store: FirebaseConstants.Storage.userProfileImages) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestUploadAccountInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.uploadAccountInfo(email: email, profileImageUrl: profileImageUrl, store: FirebaseConstants.users) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
