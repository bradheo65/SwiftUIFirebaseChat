//
//  ChatLog.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

final class ChatLog: Object {
    
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
    @Persisted var fileUrl: String? = nil

    @Persisted var timestamp = Date()
    
}
