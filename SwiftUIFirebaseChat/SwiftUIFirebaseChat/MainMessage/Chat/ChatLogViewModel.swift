//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation
import SwiftUI

import AVFoundation

final class ChatLogViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    
    @Published var errorMessage = ""

    @Published var count = 0
    @Published var image: UIImage?

    private var firestoreListener = FirebaseManager.shared.firestoreListener

    private let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    func removeListener() {
        firestoreListener?.remove()
    }
        
    func handleSendText(text: String, compltion: @escaping () -> Void) {
        let messageData = [
            FirebaseConstants.fromId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
            FirebaseConstants.toId: chatUser?.uid ?? "",
            FirebaseConstants.Text.text: text,
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
        
        compltion()
        sendMessage(text: text, messageData: messageData)
    }
     
    func handleSendImage(image: UIImage) {
        let ref = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.messageImages)
            .child(UUID().uuidString)
        
        FirebaseManager.shared.uploadImage(image: image, storageReference: ref) { result in
            switch result {
            case .success(let url):
                self.handleImageMessageData(imageURL: url, image: image) {
                    print("ok")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleSendVideo(fileUrl: URL) {
        let imageRef = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.messageImages)
            .child(UUID().uuidString)
        
        let videoRef = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.messageVideos)
            .child(UUID().uuidString)
        
        FirebaseManager.shared.uploadVideo(url: fileUrl, storageReference: videoRef) { [weak self] result in
            switch result {
            case .success(let videoURL):
                if let videoThumbnailImage = self?.thumbnailImageForVideoURL(fileURL: videoURL) {
                    FirebaseManager.shared.uploadImage(image: videoThumbnailImage, storageReference: imageRef) { [weak self] result in
                        switch result {
                        case .success(let imageUrl):
                            self?.handleVedioMessageData(imageUrl: imageUrl, videoUrl: videoURL, image: videoThumbnailImage) {
                                print("ok")
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func handleSendFile(fileUrl: URL) {
        let fileRef = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.messageFiles)
            .child(fileUrl.deletingPathExtension().lastPathComponent)
        
        FirebaseManager.shared.uploadFile(url: fileUrl, storageReference: fileRef) { result in
            switch result {
            case .success(let fileInfo):
                self.handleFileMessageData(fileInfo: fileInfo) {
                    print("Send File Message Succuess")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}

extension ChatLogViewModel {
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = chatUser?.uid else {
            return
        }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let data = try change.document.data(as: ChatMessage.self)
                            
                            self.chatMessages.append(data)
                            print("Appending chatMessage in ChatLogView")
                        } catch {
                            print(error)
                        }
                    }
                })
                
                // ScollViewProxy receiver
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    private func thumbnailImageForVideoURL(fileURL: URL) -> UIImage? {
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func handleImageMessageData(imageURL: URL, image: UIImage, compltion: @escaping () -> Void) {
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
            FirebaseConstants.toId: chatUser?.uid ?? "",
            FirebaseConstants.Image.url: imageURL.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
    
        sendMessage(text: "", messageData: messageData)
    }
    
    private func handleVedioMessageData(imageUrl: URL, videoUrl: URL, image: UIImage, compltion: @escaping () -> Void) {
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
            FirebaseConstants.toId: chatUser?.uid ?? "",
            FirebaseConstants.Image.url: imageUrl.absoluteString,
            FirebaseConstants.Video.url: videoUrl.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
    
        sendMessage(text: "", messageData: messageData)
    }
    
    private func handleFileMessageData(fileInfo: FileInfo, compltion: @escaping () -> Void) {
        let messageData = [
            FirebaseConstants.fromId: FirebaseManager.shared.auth.currentUser?.uid ?? "",
            FirebaseConstants.toId: chatUser?.uid ?? "",
            FirebaseConstants.File.url: fileInfo.url.absoluteString,
            FirebaseConstants.File.name: fileInfo.name,
            FirebaseConstants.File.type: fileInfo.contentType,
            FirebaseConstants.File.size: fileInfo.size,
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
    
        sendMessage(text: "", messageData: messageData)
    }
    
    private func sendMessage(text: String, messageData: [String: Any]) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = chatUser?.uid else {
            return
        }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        FirebaseManager.shared.handleSendMessage(
            fromDocument: document,
            toDocument: recipientMessageDocument,
            messageData: messageData
        ) {
            self.persistRecentMessage(text: text.isEmpty ? "이미지" : text)
        }
    }
    
    private func persistRecentMessage(text: String) {
        guard let chatUser = chatUser else {
            return
        }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        guard let toId = self.chatUser?.uid else {
            return
        }
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageURL: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else {
            return
        }
        
        let recipientRecentMessageDictionary = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageURL: currentUser.profileImageURL,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.timestamp: FirebaseManager.shared.timeStamp
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    
}
