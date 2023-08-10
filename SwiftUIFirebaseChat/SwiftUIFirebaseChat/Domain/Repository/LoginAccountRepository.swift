//
//  LoginAccountRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

struct LoginAccountRepository: LoginAccountRepositoryProtocol {
    private let firebaseManager = FirebaseManager.shared

    func requestLoginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success("Success to Login \(result?.user.uid ?? "")"))
        }
    }
    
}
