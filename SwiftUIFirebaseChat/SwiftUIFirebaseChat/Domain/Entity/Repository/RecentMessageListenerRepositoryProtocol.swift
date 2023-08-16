//
//  RecentMessageListenerRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase

protocol RecentMessageListenerRepositoryProtocol {
    
    func addRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void)
    func removeRecentMessageListener()
    
}
