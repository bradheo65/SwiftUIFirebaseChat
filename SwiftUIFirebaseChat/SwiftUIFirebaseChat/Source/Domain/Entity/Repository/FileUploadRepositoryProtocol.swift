//
//  FileUploadRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import SwiftUI

protocol FileUploadRepositoryProtocol {
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
    func uploadFile(url: URL, compltion: @escaping (Result<FileInfo, Error>) -> Void)
    
}
