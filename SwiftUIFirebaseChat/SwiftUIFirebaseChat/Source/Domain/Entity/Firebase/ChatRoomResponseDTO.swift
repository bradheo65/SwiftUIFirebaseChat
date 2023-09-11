//
//  ChatRoomResponseDTO.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import Foundation

import FirebaseFirestoreSwift

struct ChatRoomResponseDTO: Codable, Identifiable {
    @DocumentID var id: String?
    
    let text, email: String
    let fromId, toId: String
    let profileImageURL: String
    let timestamp: Date
}

extension ChatRoomResponseDTO {
    func toDomain() -> ChatRoomResponse {
        return .init(
            id: id,
            fromId: fromId,
            toId: toId,
            text: text,
            email: email,
            profileImageURL: profileImageURL,
            timestamp: timestamp
        )
    }
}
