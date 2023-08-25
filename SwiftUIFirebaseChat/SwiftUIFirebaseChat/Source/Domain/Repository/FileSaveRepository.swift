//
//  FileSaveRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

final class FileSaveRepository: FileSaveRepositoryProtocol {
    
    private let networkService = NetworkService.shared
    
    func save(url: URL) async throws -> URL {
        return try await networkService.downloadFile(url: url)
    }
    
}
