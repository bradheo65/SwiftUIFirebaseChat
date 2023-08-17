//
//  FileSaveUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

protocol FileSaveUseCaseProtocol {
    
    func excute(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
    
}

final class FileSaveUseCase: FileSaveUseCaseProtocol {
    
    private let repo: FileSaveRepositoryProtocol
    
    init(repo: FileSaveRepositoryProtocol) {
        self.repo = repo
    }
    
    func excute(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        repo.save(url: url) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
