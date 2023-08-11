//
//  LoginRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginRepositoryProtocol {
    
    func requestLogin(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    
}
