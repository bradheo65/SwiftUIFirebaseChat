//
//  Room.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

import RealmSwift

final class Room: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var profileImageURL = ""
    @Persisted var email = ""
    @Persisted var name = ""
    @Persisted var participants = List<FriendUser>() // 채팅방 참여자 목록
    @Persisted var latestMessage = ""
    @Persisted var fromId = ""
    @Persisted var toId = ""
    @Persisted var timestamp = Date()
}

extension Room {
    func toDomain() -> ChatRoom {
        return .init(
            id: id,
            text: latestMessage,
            email: email,
            fromId: fromId, toId: toId,
            profileImageURL: profileImageURL,
            timestamp: timestamp
        )
    }
}
