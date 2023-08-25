//
//  LogoutUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol LogoutUseCaseProtocol {
    
    func excute() throws -> String
    
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute() throws -> String {
        return try userRepo.logoutUser()
    }
    
}
