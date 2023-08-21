//
//  UserRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation

protocol UserRepositoryProtocol {
    
    func registerUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func saveUserInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func logoutUser(completion: @escaping (Result<String, Error>) -> Void)
    func fetchAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void)
    func fetchCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void)
    
}
