//
//  ChatMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import Foundation

struct ChatMessage {
    let id: String?
    let fromId, toId: String
    let text, imageUrl, videoUrl, fileUrl : String?
    let imageWidth, imageHeight: Float?
    let fileName, fileType, fileSize: String?
    let timestamp: Date
    
    var fileTitle: String? {
        if let fileName = fileName {
            
            return fileName + "." + (fileType?.suffix(3) ?? "")
        } else {
            return nil
        }
    }
    
    var fileSizes: String? {
        if let fileSize = fileSize {
            return fileSize + "MB"
        } else {
            return nil
        }
    }
}
