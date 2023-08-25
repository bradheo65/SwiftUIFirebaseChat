//
//  FileUploadRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import SwiftUI

protocol FileUploadRepositoryProtocol {
    
    func uploadImage(image: UIImage) async throws -> URL
    func uploadVideo(url: URL) async throws -> URL
    func uploadFile(url: URL) async throws -> FileInfo
    
}
