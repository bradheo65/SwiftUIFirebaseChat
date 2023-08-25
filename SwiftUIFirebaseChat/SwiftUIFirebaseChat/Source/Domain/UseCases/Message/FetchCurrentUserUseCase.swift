//
//  FetchCurrentUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol FetchCurrentUserUseCaseProtocol {
    
    func excute() async throws -> ChatUser?

}

final class FetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func excute() async throws -> ChatUser? {
        return try await userRepo.fetchCurrentUser()
    }
    
}
