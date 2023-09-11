//
//  ChatMessageResponseDTO.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import Foundation

import FirebaseFirestoreSwift

struct ChatMessageResponseDTO: Codable, Identifiable {
    @DocumentID var id: String?
    
    let fromId, toId: String
    let text, imageUrl, videoUrl, fileUrl : String?
    let imageWidth, imageHeight: Float?
    let timestamp: Date
    let fileName, fileType, fileSize: String?
}

extension ChatMessageResponseDTO {
    func toDomain() -> ChatMessageResponse {
        return .init(
            id: id,
            fromId: fromId,
            toId: toId,
            text: text,
            imageUrl: imageUrl,
            videoUrl: videoUrl,
            fileUrl: fileUrl,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            fileName: fileName,
            fileType: fileType,
            fileSize: fileSize,
            timestamp: timestamp
        )
    }
}
