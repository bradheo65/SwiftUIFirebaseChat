//
//  SendMessageRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

protocol MessagingRepositoryProtocol {
    
    func fetchChatMessage(chatUser: ChatUser, completion: @escaping (ChatLog) -> Void)
    func fetchNextChatMessage(from date: Date?, chatUser: ChatUser, completion: @escaping (ChatLog) -> Void)
    func sendText(text: String, chatUser: ChatUser) async throws -> String
    func sendImage(url: URL, image: UIImage, chatUser: ChatUser) async throws -> String
    func sendVideo(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser) async throws -> String
    func sendFile(fileInfo: FileInfo, chatUser: ChatUser) async throws -> String
    func sendRecentMessage(text: String, chatUser: ChatUser) async throws -> String
    
}
