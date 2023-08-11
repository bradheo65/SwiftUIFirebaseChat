//
//  CreateAccountRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

protocol CreateAccountRepositoryProtocol {
    
    func requestCreateAccount(email: String, password: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void)
    func requestUploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
    func requestUploadAccountInfo(email: String, imageProfileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
    
}
