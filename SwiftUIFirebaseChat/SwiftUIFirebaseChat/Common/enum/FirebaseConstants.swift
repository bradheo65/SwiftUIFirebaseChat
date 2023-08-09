//
//  FirebaseConstants.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

enum FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let timestamp = "timestamp"
    static let profileImageURL = "profileImageURL"
    static let email = "email"
    static let users = "users"
    static let uid = "uid"
    static let messages = "messages"
    static let recentMessages = "recent_messages"
    
    enum Storage {
        static let userProfileImages = "user_profile_images"
        static let messageImages = "message_images"
        static let messageVideos = "message_videos"
        static let messageFiles = "message_files"
    }
    
    enum Text {
        static let text = "text"
    }
    
    enum Image {
        static let url = "imageUrl"
        static let width = "imageWidth"
        static let height = "imageHeight"
    }
    
    enum Video {
        static let url = "videoUrl"
    }
    
    enum File {
        static let url = "fileUrl"
        static let name = "fileName"
        static let type = "fileType"
        static let size = "fileSize"
    }
}
