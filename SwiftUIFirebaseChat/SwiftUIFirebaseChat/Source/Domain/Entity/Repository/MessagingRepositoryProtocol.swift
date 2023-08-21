//
//  SendMessageRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/16.
//

import Foundation
import SwiftUI

protocol MessagingRepositoryProtocol {
    
    func thumbnailImageForVideoURL(fileURL: URL) -> UIImage?
    func sendText(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendImage(url: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendVideo(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendFile(fileInfo: FileInfo, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    func sendRecentMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void)
    
}
