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

struct CreateAccountUseCase: CreateAccountUseCaseProtocol {
    var repo = CreateAccountRepository()
    
    func excute(email: String, password: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = image else {
            return
        }
        
        repo.requestCreateUser(email: email, password: password, image: image) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
