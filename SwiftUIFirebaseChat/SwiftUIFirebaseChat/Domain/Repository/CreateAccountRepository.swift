//
//  CreateAccountRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

struct CreateAccountRepository: CreateAccountRepositoryProtocol {
    
    private let firebaseManager = FirebaseManager.shared
    
    func requestCreateUser(email: String, password: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.requestImageToStorage(email: email, image: image) { result in
                switch result {
                case .success(let message):
                    completion(.success(message))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func requestImageToStorage(email: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = firebaseManager.auth.currentUser?.uid else {
            return
        }
        
        let ref = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.userProfileImages)
            .child(uid)
        
        firebaseManager.uploadImage(image: image, storageReference: ref) { result in
            switch result {
            case .success(let url):
                requestUpdateStoreUserInformation(email: email, imageProfileURL: url) { result in
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
    }
    
    func requestUpdateStoreUserInformation(email: String, imageProfileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageURL: imageProfileURL.absoluteString
        ]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("Success"))
            }
    }
}
