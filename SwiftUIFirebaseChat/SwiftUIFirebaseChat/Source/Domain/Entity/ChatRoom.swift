//
//  ChatRoom.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import Foundation

struct ChatRoom {
    let id: String?
    let fromId, toId, text, email, profileImageURL: String
    let timestamp: Date
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
