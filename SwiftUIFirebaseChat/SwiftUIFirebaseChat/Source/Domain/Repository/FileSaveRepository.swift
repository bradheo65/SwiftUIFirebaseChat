//
//  FileSaveRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

final class FileSaveRepository: FileSaveRepositoryProtocol {
    private let networkService = NetworkService.shared
    
    /**
     파일을 다운로드하여 저장하는 함수
     
     이 함수는 주어진 URL에서 파일을 다운로드하여 로컬에 저장하고, 저장된 파일의 로컬 URL을 반환합니다.
     
     - Parameters:
       - url: 다운로드할 파일의 URL
     
     - Throws: 파일 다운로드나 저장에 실패한 경우 에러를 던집니다.

     - Returns: 다운로드 및 저장이 완료된 파일의 로컬 URL
     */
    func save(url: URL) async throws -> URL {
        return try await networkService.downloadFile(url: url)
    }
}
