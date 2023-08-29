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
    
    /**
     이미지를 업로드하는 함수

     이 함수는 주어진 UIImage를 압축하여 Firebase에 업로드하고, 업로드된 이미지의 URL을 반환하는 역할을 합니다.

     - Parameters:
       - image: 업로드할 이미지

     - Throws:
       - FileUploadError.compressionFailed: 이미지 압축 실패 시 에러를 던짐

     - Returns: 업로드된 이미지의 URL
     */
    func uploadImage(image: UIImage) async throws -> URL {
        // 이미지를 압축하여 데이터를 생성합니다.
        guard let compressedImageData = image.jpegData(compressionQuality: 0.5) else {
            throw FileUploadError.compressionFailed
        }
   
        // 압축된 이미지 데이터를 Firebase에 업로드하고 업로드된 이미지의 URL을 받아옵니다.
        let uploadImageUrl = try await firebaseService.uploadImage(
            data: compressedImageData,
            store: FirebaseConstants.Storage.messageImages
        )
        
        return uploadImageUrl
    }
    
    /**
     비디오를 업로드하는 함수

     이 함수는 주어진 URL에서 비디오 데이터를 가져와 Firebase에 업로드하고, 업로드된 비디오의 URL을 반환하는 역할을 합니다.

     - Parameters:
       - url: 업로드할 비디오의 URL

     - Throws:
       - FileUploadError.invalidUrl: 유효하지 않은 URL일 경우 에러를 던짐

     - Returns: 업로드된 비디오의 URL
     */
    func uploadVideo(url: URL) async throws -> URL {
        // 주어진 URL에서 비디오 데이터를 가져옵니다.
        guard let videoData = try? Data(contentsOf: url) as Data? else {
            throw FileUploadError.invalidUrl
        }
        
        // 비디오 데이터를 Firebase에 업로드하고 업로드된 비디오의 URL을 받아옵니다.
        let uploadVideoUrl = try await firebaseService.uploadVideo(
            data: videoData,
            store: FirebaseConstants.Storage.messageVideos
        )
        
        return uploadVideoUrl
    }
    
    /**
     파일을 업로드하는 함수

     이 함수는 주어진 URL에서 파일을 가져와 Firebase에 업로드하고, 업로드된 파일의 정보를 반환하는 역할을 합니다.

     - Parameters:
       - url: 업로드할 파일의 URL

     - Throws:
       - 기타 에러: 파일 업로드 과정에서 발생한 에러를 전달

     - Returns: 업로드된 파일의 정보 (FileInfo)
     */
    func uploadFile(url: URL) async throws -> FileInfo {
        return try await firebaseService.uploadFile(url: url, store: FirebaseConstants.Storage.messageFiles)
    }
    
}
