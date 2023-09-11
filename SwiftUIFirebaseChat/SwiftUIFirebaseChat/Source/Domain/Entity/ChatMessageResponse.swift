//
//  ChatMessageResponse.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import Foundation

struct ChatMessageResponse {
    let id: String?
    let fromId, toId: String
    let text, imageUrl, videoUrl, fileUrl : String?
    let imageWidth, imageHeight: Float?
    let fileName, fileType, fileSize: String?
    let timestamp: Date
}
