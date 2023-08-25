//
//  FileSaveUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

protocol FileSaveUseCaseProtocol {
    
    func excute(url: URL) async throws -> URL
    
}

final class FileSaveUseCase: FileSaveUseCaseProtocol {
    
    private let repo: FileSaveRepositoryProtocol
    
    init(repo: FileSaveRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute(url: URL) async throws -> URL {
        return try await repo.save(url: url)
    }
    
}
