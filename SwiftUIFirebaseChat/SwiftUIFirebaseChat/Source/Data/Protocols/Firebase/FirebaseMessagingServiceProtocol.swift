//
//  FirebaseMessagingServiceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation
import SwiftUI

protocol FirebaseMessagingServiceProtocol {
    
    func sendTextMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendImageMessage(imageURL: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendVideoMessage(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendFileMessage(fileInfo: FileInfo, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendRecentMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendMessage(fromId: String, toId: String, messageData: [String: Any], completion: @escaping (Result<String, Error>) -> Void)
    
}
