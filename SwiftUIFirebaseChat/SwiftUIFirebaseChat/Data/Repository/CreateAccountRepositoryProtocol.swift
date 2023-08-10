//
//  CreateAccountRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

protocol CreateAccountRepositoryProtocol {
    
    func requestCreateUser(email: String, password: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void)
    func requestImageToStorage(email: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void)
    func requestUpdateStoreUserInformation(email: String, imageProfileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
    
}
