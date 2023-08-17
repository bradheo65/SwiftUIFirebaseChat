//
//  RemoveRecentMessageListenerUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol RemoveRecentMessageListenerUseCaseProtocol {
    
    func excute()
    
}

final class RemoveRecentMessageListenerUseCase: RemoveRecentMessageListenerUseCaseProtocol {
    
    private let repo: RecentMessageListenerRepositoryProtocol
    
    init(repo: RecentMessageListenerRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute() {
        repo.removeRecentMessageListener()
    }
    
}
