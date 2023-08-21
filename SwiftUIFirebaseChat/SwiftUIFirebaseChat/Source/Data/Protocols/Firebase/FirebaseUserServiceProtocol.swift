//
//  FirebaseUserServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/18.
//

import Foundation

protocol FirebaseUserServiceProtocol {
    
    func registerUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func saveUserInfo(email: String, profileImageUrl: URL, store: String, completion: @escaping (Result<String, Error>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func logoutUser(completion: @escaping (Result<String, Error>) -> Void)
    func fetchAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void)
    func fetchCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void)
    
}
