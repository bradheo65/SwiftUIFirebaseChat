//
//  FirebaseFileUploadServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import SwiftUI

protocol FirebaseFileUploadServiceProtocol {
        
    func uploadImage(data: Data, store: String) async throws -> URL
    func uploadVideo(data: Data, store: String) async throws -> URL
    func uploadFile(url: URL, store: String) async throws -> FileInfo
    
}
