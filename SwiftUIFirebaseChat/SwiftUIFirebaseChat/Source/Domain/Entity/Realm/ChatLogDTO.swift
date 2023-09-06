//
//  ChatLogDTO.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import Foundation

import RealmSwift

final class ChatLogDTO: Object, Identifiable {
    
    @Persisted(primaryKey: true) var uid: String = UUID().uuidString
    @Persisted var id: String = ""
    @Persisted var fromId = ""
    @Persisted var toId = ""
    @Persisted var text: String? = nil
    
    @Persisted var imageUrl: String? = nil
    @Persisted var videoUrl: String? = nil
    @Persisted var imageWidth: Float? = nil
    @Persisted var imageHeight: Float? = nil
    
    @Persisted var fileTitle: String? = nil
    @Persisted var fileSizes: String? = nil
    @Persisted var fileType: String? = nil
    @Persisted var fileUrl: String? = nil

    @Persisted var timestamp = Date()
    
}

extension ChatLogDTO {
    func toDomain() -> ChatLog {
        return .init(
            uid: uid,
            id: id,
            fromId: fromId,
            toId: toId,
            text: text,
            imageUrl: imageUrl,
            videoUrl: videoUrl,
            fileTitle: fileTitle,
            fileSizes: fileSizes,
            fileType: fileType,
            fileUrl: fileUrl,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            timestamp: timestamp
        )
    }
}
