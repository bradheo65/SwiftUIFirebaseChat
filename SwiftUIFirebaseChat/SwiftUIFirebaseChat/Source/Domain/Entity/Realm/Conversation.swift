//
//  Conversation.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

import RealmSwift

final class Conversation: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var room: Room? // 해당 대화의 채팅방
    @Persisted var messages = List<Message>() // 대화 메시지 목록
    @Persisted var timestamp = Date()
}
