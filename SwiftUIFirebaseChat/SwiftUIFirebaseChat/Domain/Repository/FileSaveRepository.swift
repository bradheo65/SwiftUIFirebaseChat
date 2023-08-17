//
//  FileSaveRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

final class FileSaveRepository: FileSaveRepositoryProtocol {
    
    private let networkService = NetworkService.shared
    
    func save(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        networkService.downloadFile(url: url) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
