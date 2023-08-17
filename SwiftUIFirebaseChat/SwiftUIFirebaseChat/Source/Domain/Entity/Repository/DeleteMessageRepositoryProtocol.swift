//
//  DeleteMessageRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol DeleteMessageRepositoryProtocol {
    
    func deleteChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void)
    func deleteRecentChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void)
    
}
