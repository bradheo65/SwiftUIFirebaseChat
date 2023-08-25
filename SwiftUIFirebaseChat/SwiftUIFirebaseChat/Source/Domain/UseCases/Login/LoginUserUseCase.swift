//
//  LoginUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginUserUseCaseProtocol {
    
    func execute(email: String, password: String) async throws -> String
    
}

final class LoginUserUseCase: LoginUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func execute(email: String, password: String) async throws -> String {
        return try await userRepo.loginUser(email: email, password: password)
    }
    
}
