//
//  ChatMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import Foundation

import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let fromId, toId: String
    let text, imageUrl, videoUrl, fileUrl : String?
    let imageWidth, imageHeight: Float?
    let timestamp: Date
    
    let fileName, fileType, fileSize: String?
    
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
