//
//  FileUploadRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

enum FileUploadError: Error {
    case compressionFailed
    case invalidUrl
}

final class FileUploadRepository: FileUploadRepositoryProtocol {
    
    private let firebaseService: FirebaseFileUploadServiceProtocol
    
    init(firebaseService: FirebaseFileUploadServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func uploadImage(image: UIImage) async throws -> URL {
        guard let compressedImageData = image.jpegData(compressionQuality: 0.5) else {
            throw FileUploadError.compressionFailed
        }
   
        let uploadImageUrl = try await firebaseService.uploadImage(
            data: compressedImageData,
            store: FirebaseConstants.Storage.messageImages
        )
        
        return uploadImageUrl
    }
    
    func uploadVideo(url: URL) async throws -> URL {
        guard let videoData = try? Data(contentsOf: url) as Data? else {
            throw FileUploadError.invalidUrl
        }
        
        let uploadVideoUrl = try await firebaseService.uploadVideo(
            data: videoData,
            store: FirebaseConstants.Storage.messageVideos
        )
        
        return uploadVideoUrl
    }
    
    func uploadFile(url: URL) async throws -> FileInfo {
        return try await firebaseService.uploadFile(url: url, store: FirebaseConstants.Storage.messageFiles)
    }
    
}
