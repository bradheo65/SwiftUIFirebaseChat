//
//  ChatList.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

final class ChatList: Object, Identifiable, Comparable {
    
    @objc dynamic var id = ""
    @objc dynamic var text = ""
    @objc dynamic var username: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var fromId = ""
    @objc dynamic var toId: String = ""
    @objc dynamic var profileImageURL: String = ""
    @objc dynamic var timestamp: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
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
    
    static func < (lhs: ChatList, rhs: ChatList) -> Bool {
        return lhs.timestamp.timeIntervalSince1970 > rhs.timestamp.timeIntervalSince1970
    }
    
}
