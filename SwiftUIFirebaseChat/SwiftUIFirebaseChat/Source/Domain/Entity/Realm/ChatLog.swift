//
//  ChatLog.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

class ChatLog: Object {
    
    @objc dynamic var id: String? = nil
    @objc dynamic var fromId = ""
    @objc dynamic var toId = ""
    @objc dynamic var text: String? = nil
    @objc dynamic var imageUrl: String? = nil
    @objc dynamic var videoUrl: String? = nil
    @objc dynamic var fileUrl: String? = nil
    var imageWidth = RealmOptional<Float>()
    var imageHeight = RealmOptional<Float>()
    @objc dynamic var timestamp = Date()
    
    @objc dynamic var fileTitle: String? = nil
    @objc dynamic var fileSizes: String? = nil
    
}
