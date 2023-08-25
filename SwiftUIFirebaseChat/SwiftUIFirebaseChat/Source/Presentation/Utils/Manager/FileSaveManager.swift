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
    
    func save(name: String, at: URL) async throws -> String {
        guard let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileSaveManagerError.noDocumentUrl
        }
        
        let directoryUrl = documentUrl.appendingPathComponent(name)
        
        do {
            try fileManager.copyItem(at: at, to: directoryUrl)
            
            let message = "Success to file save"
            
            return message
        } catch {
            throw FileSaveManagerError.saveFail
        }
    }
    
}
