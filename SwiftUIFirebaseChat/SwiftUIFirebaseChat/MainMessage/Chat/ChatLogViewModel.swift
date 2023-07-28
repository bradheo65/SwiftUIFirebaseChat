//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

import Firebase

final class ChatLogViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    
    @Published var errorMessage = ""

    @Published var count = 0

    var firestoreListener: ListenerRegistration?

    private let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
        
    func handleSendText(text: String, compltion: @escaping () -> Void) {
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
        
        let messageData = [
            FirebaseConstants.fromId : fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: text,
            FirebaseConstants.timestamp: Timestamp()
        ] as [String : Any]
        
        FirebaseManager.shared.handleSendMessage(
            fromDocument: document,
            toDocument: recipientMessageDocument,
            messageData: messageData
        ) {
            print("handleSendMessage ok")
            compltion()
            self.persistRecentMessage(text: text) {
                print("persistRecentMessage ok")
            }
        }
    }
     
    func handleSendImage(image: UIImage) {
        let ref = FirebaseManager.shared.storage.reference()
            .child("message_images")
            .child(UUID().uuidString)
        
        FirebaseManager.shared.uploadImage(image: image, storageReference: ref) { result in
            switch result {
            case .success(let url):
                self.handleImageMessageData(imageUrl: url.absoluteString, image: image) {
                    print("ok")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension ChatLogViewModel {
    
    private func handleImageMessageData(imageUrl: String, image: UIImage?, compltion: @escaping () -> Void) {
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

        guard let image = image else {
            return
        }
        
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId : fromId,
            FirebaseConstants.toId: toId,
            "imageUrl": imageUrl,
            "imageWidth": CGFloat(200),
            "imageHeight": CGFloat(height / width * 200),
            FirebaseConstants.timestamp: Timestamp()
        ] as [String : Any]
    
        FirebaseManager.shared.handleSendMessage(
            fromDocument: document,
            toDocument: recipientMessageDocument,
            messageData: messageData
        ) {
            self.persistRecentMessage(text: "이미지") {
                print("persistRecentMessage ok")
            }
        }
    }
    
    private func persistRecentMessage(text: String, compltion: @escaping () -> Void) {
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
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageURL: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email
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
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageURL: currentUser.profileImageURL,
            FirebaseConstants.email: currentUser.email
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
    
}
