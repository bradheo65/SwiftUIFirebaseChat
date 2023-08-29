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
    
    /**
     파일을 저장하고 저장된 파일의 URL을 반환하는 함수

     이 함수는 주어진 파일 URL을 사용하여 파일을 저장하고, 저장된 파일의 URL을 비동기적으로 반환하는 역할을 합니다.

     - Parameters:
       - url: 저장할 파일의 파일 URL

     - Throws:
       - 기타 에러: 파일 저장 과정에서 발생한 에러를 전달

     - Returns: 저장된 파일의 URL
     */
    func excute(url: URL) async throws -> URL {
        return try await repo.save(url: url)
    }
    
}
