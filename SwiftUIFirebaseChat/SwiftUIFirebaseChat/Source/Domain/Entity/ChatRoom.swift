//
//  ChatRoom.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/11.
//

import Foundation

struct ChatRoom: Identifiable, Comparable, Hashable {
    let id, text, email, fromId, toId, profileImageURL: String
    let timestamp: Date
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(timestamp) {
            formatter.dateFormat = "hh:mm"
        } else {
            formatter.dateFormat = "MM. dd"
        }
        return formatter.string(from: timestamp)
    }
    
    static func < (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        return lhs.timestamp.timeIntervalSince1970 > rhs.timestamp.timeIntervalSince1970
    }
}
