//
//  FirebaseFileUploadServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import SwiftUI

protocol FirebaseFileUploadServiceProtocol {
        
    func uploadImage(image: UIImage, store: String, compltion: @escaping (Result<URL, Error>) -> Void)
    func uploadVideo(url: URL, store: String, compltion: @escaping (Result<URL, Error>) -> Void)
    func uploadFile(url: URL, store: String, compltion: @escaping (Result<FileInfo, Error>) -> Void)
    
}
