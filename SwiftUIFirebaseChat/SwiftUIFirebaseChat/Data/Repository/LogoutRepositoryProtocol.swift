//
//  LogoutRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol LogoutRepositoryProtocol {
    
    func requestLogout(completion: @escaping (Result<String, Error>) -> Void)
    
}
