//
//  DeleteRecentMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol DeleteRecentMessageUseCaseProtocol {
    
    func execute(toId: String) async throws -> String

}

final class DeleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    func execute(toId: String) async throws -> String {
        let (_) = try await userRepo.deleteChatMessage(toId: toId)
        let deleteRecentMessage = try await userRepo.deleteRecentMessage(toId: toId)
        
        return deleteRecentMessage
    }
    
}
