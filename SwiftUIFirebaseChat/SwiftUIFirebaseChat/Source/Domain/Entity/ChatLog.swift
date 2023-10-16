//
//  ChatLogDTO.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

struct ChatLog: Identifiable, Hashable {
    let id, fromId, toId: String
    let text, imageUrl, videoUrl, fileTitle, fileSizes, fileType, fileUrl: String?
    let imageWidth, imageHeight: Float?
    
    var isPlay: PlayStatus?
    let timestamp: Date
    
}

enum PlayStatus: String, Codable {
    case play
    case pause
    case stop
}
