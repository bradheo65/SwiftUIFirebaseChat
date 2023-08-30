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
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    static func < (lhs: ChatList, rhs: ChatList) -> Bool {
        return lhs.timestamp.timeIntervalSince1970 > rhs.timestamp.timeIntervalSince1970
    }
    
}
