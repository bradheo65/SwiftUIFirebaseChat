//
//  LoginAccountRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginAccountRepositoryProtocol {
    
    func requestLoginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    
}
