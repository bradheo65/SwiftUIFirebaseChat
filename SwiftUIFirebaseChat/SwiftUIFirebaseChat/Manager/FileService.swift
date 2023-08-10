//
//  FileService.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

enum FileServiceError: Error {
    case noDocumentUrl
    case saveFail
}

final class FileService {
    static let shared = FileService()
    
    private init() { }
    
    private let fileManager = FileManager.default
    
    func saveFile(name: String, at: URL) async throws -> Result<String, FileServiceError> {
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(.noDocumentUrl)
        }
        
        let directoryUrl = documentUrl.appendingPathComponent(name)
        
        do {
            try fileManager.copyItem(at: at, to: directoryUrl)
            return .success("Success to file save")
        } catch {
            return .failure(.saveFail)
        }
    }
    
}
