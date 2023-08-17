//
//  FileSaveManager.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

enum FileSaveManagerError: Error {
    case noDocumentUrl
    case saveFail
}

final class FileSaveManager {
    
    static let shared = FileSaveManager()
    
    private init() { }
    
    private let fileManager = FileManager.default
    
    func save(name: String, at: URL, completion: @escaping (Result<String, FileSaveManagerError>) -> Void) {
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(.failure(.noDocumentUrl))
            return
        }
        
        let directoryUrl = documentUrl.appendingPathComponent(name)
        
        do {
            try fileManager.copyItem(at: at, to: directoryUrl)
            completion(.success("Success to file save"))
        } catch {
            completion(.failure(.saveFail))
        }
    }
    
}
