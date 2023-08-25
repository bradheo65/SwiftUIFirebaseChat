//
//  FetchAllUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/11.
//

import Foundation

protocol FetchAllUserUseCaseProtocol {
    
    func excute() async throws -> [ChatUser]
    
}

final class FetchAllUserUseCase: FetchAllUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute() async throws -> [ChatUser] {
        return try await userRepo.fetchAllUsers()
    }
    
}
