//
//  RegisterUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

protocol RegisterUserUseCaseProtocol {
    
    func excute(email: String, password: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class RegisterUserUseCase: RegisterUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    private let fileUploadRepo: FileUploadRepositoryProtocol

    init(userRepo: UserRepositoryProtocol, fileUploadRepo: FileUploadRepositoryProtocol) {
        self.userRepo = userRepo
        self.fileUploadRepo = fileUploadRepo
    }
    
    func excute(email: String, password: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = image else {
            return
        }
        
        userRepo.registerUser(email: email, password: password) { result in
            switch result {
            case .success(_):
                self.fileUploadRepo.uploadImage(image: image) { result in
                    switch result {
                    case .success(let url):
                        self.userRepo.saveUserInfo(email: email, profileImageUrl: url) { result in
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
