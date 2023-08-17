//
//  GetUserRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol GetUserRepositoryProtocol {
    
    func requestAllUser(completion: @escaping (Result<ChatUser, Error>) -> Void)
    func requestCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void)
    
}
