//
//  ChatRoomDTO.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

final class ChatRoomDTO: Object, Identifiable {
    @objc dynamic var id = ""
    @objc dynamic var text = ""
    @objc dynamic var username = ""
    @objc dynamic var email = ""
    @objc dynamic var fromId = ""
    @objc dynamic var toId = ""
    @objc dynamic var profileImageURL = ""
    @objc dynamic var timestamp = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ChatRoomDTO {
    func toDomain() -> ChatRoom {
        return .init(
            id: id,
            text: text,
            username: username,
            email: email,
            fromId: fromId,
            toId: toId,
            profileImageURL: profileImageURL,
            timestamp: timestamp
        )
    }
}
