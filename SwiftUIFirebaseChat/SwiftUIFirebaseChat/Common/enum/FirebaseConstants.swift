//
//  FirebaseConstants.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

enum FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let profileImageURL = "profileImageURL"
    static let email = "email"
    static let users = "users"
    static let uid = "uid"
    static let messages = "messages"
    static let recentMessages = "recent_messages"
    
    enum storage {
        static let userProfileImages = "user_profile_images"
        static let messageImages = "message_images"
        static let messageVideos = "message_videos"
    }
}
