//
//  ChatUser.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/23.
//

import Foundation

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    
    let uid, email, profileImageURL: String
    
    var username: String {
           email.components(separatedBy: "@").first ?? email
       }
}
