//
//  ChatUser.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/23.
//

struct ChatUser {
    let uid, email, profileImageURL: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
    }
}
