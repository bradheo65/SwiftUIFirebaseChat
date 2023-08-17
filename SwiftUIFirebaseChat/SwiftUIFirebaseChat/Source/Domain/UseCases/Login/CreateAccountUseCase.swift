//
//  CreateAccountUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

protocol CreateAccountUseCaseProtocol {
    
    func excute(email: String, password: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void)
    
}

final class CreateAccountUseCase: CreateAccountUseCaseProtocol {
    
    private let repo: CreateAccountRepositoryProtocol
    
    init(repo: CreateAccountRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute(email: String, password: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = image else {
            return
        }
        
        repo.requestCreateAccount(email: email, password: password, image: image) { result in
            switch result {
            case .success(_):
                self.repo.requestUploadImage(image: image) { result in
                    switch result {
                    case .success(let url):
                        self.repo.requestUploadAccountInfo(email: email, profileImageUrl: url) { result in
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
