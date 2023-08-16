//
//  CreateAccountRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

struct CreateAccountRepository: CreateAccountRepositoryProtocol {
    
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
        firebaseService.uploadImage(image: image) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestUploadAccountInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseService.uploadAccountInfo(email: email, profileImageUrl: profileImageUrl) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
