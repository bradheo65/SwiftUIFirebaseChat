//
//  CreateAccountRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

struct CreateAccountRepository: CreateAccountRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared
    
    func requestCreateAccount(email: String, password: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        firebaseManager.handleCreateAccount(email: email, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestUploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let uid = firebaseManager.auth.currentUser?.uid else {
            return
        }
        
        let ref = firebaseManager.storage.reference()
            .child(FirebaseConstants.Storage.userProfileImages)
            .child(uid)
        
        firebaseManager.uploadImage(image: image, storageReference: ref) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestUploadAccountInfo(email: String, imageProfileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = firebaseManager.auth.currentUser?.uid else {
            return
        }
        
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageURL: imageProfileURL.absoluteString
        ]
        
        firebaseManager.uploadDataToFirestore(documentName: FirebaseConstants.users, data: userData) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
