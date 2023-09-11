//
//  ChatRoomResponse.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import Foundation

struct ChatRoomResponse {
    let id: String?
    let fromId, toId, text, email, profileImageURL: String
    let timestamp: Date
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
}
