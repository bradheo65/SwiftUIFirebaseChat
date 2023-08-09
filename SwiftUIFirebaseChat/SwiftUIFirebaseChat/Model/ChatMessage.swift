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
    let imageWidth, imageHeight: CGFloat?
    let timestamp: Date
    
    private let fileName, fileType, fileSize: String?
    
    var fileTitle: String {
        return (fileName ?? "") + "." + (fileType?.suffix(3) ?? "")
    }
    
    var fileSizes: String {
        return (fileSize ?? "") + "MB"
    }
}
