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
    let text, imageUrl, videoUrl: String?
    let imageWidth, imageHeight: CGFloat?
    let timestamp: Date
}
