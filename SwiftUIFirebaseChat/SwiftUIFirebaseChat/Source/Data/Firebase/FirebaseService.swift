//
//  FirebaseService.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase
import FirebaseStorage

enum FirebaseError: Error {
    case authUserNotFound
}

final class FirebaseService: NSObject {
    
    private let auth: Auth
    private let storage: Storage
    private let firestore: Firestore
    
    private var chatMessageListener: ListenerRegistration?
    private var recentMessageListener: ListenerRegistration?
    
    var currentUser: ChatUser?
    var timeStamp: Timestamp {
        get {
            return Timestamp()
        }
    }
    
    static let shared = FirebaseService()
    
    private override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
 
extension FirebaseService: FirebaseUserServiceProtocol {
    
    func registerUser(email: String, password: String) async throws -> String {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let message = result.user.uid
            
            return message
        } catch {
            throw error
        }
    }
    
    func saveUserInfo(store: String, currentUser: ChatUser, userData: [String: Any]) async throws -> String {
        do {
            try await firestore.collection(store)
                .document(currentUser.uid)
                .setData(userData)
            
            let message = "Success upload data to Firestore"
            
            return message
        } catch {
            throw error
        }
    }
    
    func loginUser(email: String, password: String) async throws -> String {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            let documentSnapshot = try await firestore
                .collection(FirebaseConstants.users)
                .document(result.user.uid)
                .getDocument()
            
            let currentUser = try documentSnapshot.data(as: ChatUser.self)
            self.currentUser = currentUser
            
            return result.user.uid
        } catch {
            throw error
        }
    }
    
    func logoutUser() throws -> String {
        do {
            try auth.signOut()
            
            return "Success to Logout"
        } catch {
            throw error
        }
    }
    
    func fetchCurrentUser() async throws -> ChatUser? {
        guard let authCurrentUser = auth.currentUser else {
            throw FirebaseError.authUserNotFound
        }
        
        do {
            let documentSnapshot = try await firestore.collection(FirebaseConstants.users)
                .document(authCurrentUser.uid)
                .getDocument()
            
            let currentUser = try documentSnapshot.data(as: ChatUser.self)
            self.currentUser = currentUser
            
            return currentUser
        } catch {
            throw error
        }
    }
    
    func fetchAllUsers() async throws -> [ChatUser]  {
        do {
            let querySnapshot = try await firestore
                .collection(FirebaseConstants.users)
                .getDocuments()
            
            var chatUsers: [ChatUser] = []
            
            try querySnapshot.documents.forEach { snapshot in
                do {
                    let user = try snapshot.data(as: ChatUser.self)
                    
                    if user.id != self.auth.currentUser?.uid {
                        chatUsers.append(user)
                    }
                } catch {
                    throw error
                }
            }
            return chatUsers
        } catch {
            throw error
        }
    }
    
    func deleteChatMessage(toId: String) async throws -> String {
        guard let authCurrentUser = auth.currentUser else {
            throw FirebaseError.authUserNotFound
        }
        
        do {
            let querySnapshot = try await firestore
                .collection(FirebaseConstants.messages)
                .document(authCurrentUser.uid)
                .collection(toId)
                .getDocuments()
        
            for snapshot in querySnapshot.documents {
                try await firestore
                    .collection(FirebaseConstants.messages)
                    .document(authCurrentUser.uid)
                    .collection(toId)
                    .document(snapshot.documentID)
                    .delete()
            }
            let message = "Success to Delete chat Message"
            
            return message
        } catch {
            throw error
        }
    }
    
    func deleteRecentMessage(toId: String) async throws -> String {
        guard let authCurrentUser = auth.currentUser else {
            throw FirebaseError.authUserNotFound
        }
        
        do {
            try await firestore
                .collection(FirebaseConstants.recentMessages)
                .document(authCurrentUser.uid)
                .collection(FirebaseConstants.messages)
                .document(toId)
                .delete()
            
            let message = "Success to Delete recent Message"
            
            return message
        }
        catch {
            throw error
        }
    }
    
}

extension FirebaseService: FirebaseMessagingServiceProtocol {
    
    func sendMessage(fromId: String, toId: String, messageData: [String: Any]) async throws -> String {
        let document = firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let recentDocument = firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
                
        do {
            try await document.setData(messageData)
            try await recentDocument.setData(messageData)
            
            let message = "Success to send user message"
            
            return message
        } catch {
            throw error
        }
        
    }
    
    func sendRecentMessage(text: String, currentUser: ChatUser, chatUser: ChatUser, userMessage: [String: Any], recentMessage: [String: Any]) async throws -> String {
        let document = firestore
            .collection(FirebaseConstants.recentMessages)
            .document(currentUser.uid)
            .collection(FirebaseConstants.messages)
            .document(chatUser.uid)

        let recentDocument = firestore
            .collection(FirebaseConstants.recentMessages)
            .document(chatUser.uid)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
        
        do {
            try await document.setData(userMessage)
            try await recentDocument.setData(recentMessage)
            
            let message = "Success to send recent message"
            
            return message
        } catch {
            throw error
        }
    }
    
}

extension FirebaseService: FirebaseFileUploadServiceProtocol {
    
    func uploadImage(data: Data, store: String) async throws -> URL {
        let imageRef = storage.reference()
            .child(store)
            .child(UUID().uuidString)
        
        do {
            let (_) = try await imageRef.putDataAsync(data)
            let url = try await imageRef.downloadURL()
            
            return url
        } catch {
           throw error
        }
    }
    
    func uploadVideo(data: Data, store: String) async throws -> URL {
        let videoRef = storage.reference()
            .child(store)
            .child(UUID().uuidString)

        let metaData = StorageMetadata()
        metaData.contentType = "video/mp4"
        
        do {
            let (_) = try await videoRef.putDataAsync(data, metadata: metaData)
            let videoDownloadUrl = try await videoRef.downloadURL()
            
            return videoDownloadUrl
        }
        catch {
            throw error
        }
    }
    
    func uploadFile(url: URL, store: String) async throws -> FileInfo {
        let fileRef = storage.reference()
            .child(store)
            .child(url.deletingPathExtension().lastPathComponent)
        
        do {
            let (_) = try await fileRef.putFileAsync(from: url, metadata: nil)
            let uploadUrl = try await fileRef.downloadURL()
            let metaData = try await fileRef.getMetadata()
            
            let contentType = metaData.contentType ?? ""
            let fileSize = metaData.size
            let size = String(format: "%.2f", Float(fileSize) / 1000000)

            let fileInfo = FileInfo(
                url: uploadUrl,
                name: uploadUrl.deletingPathExtension().lastPathComponent,
                contentType: contentType,
                size:size
            )
            
            return fileInfo
        } catch {
            throw error
        }
    }
    
}

extension FirebaseService: FirebaseChatListenerProtocol {
    
    func listenForChatMessage(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        chatMessageListener = firestore
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .collection(chatUser.uid)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let chatMessage = try change.document.data(as: ChatMessage.self)
                            
                            completion(.success(chatMessage))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                })
            }
    }
    
    func stopListenForChatMessage() {
        chatMessageListener?.remove()
    }
    
    func listenForRecentMessage(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        recentMessageListener = firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    completion(.success(change))
                }
            }
    }
    
    func stopListenForRecentMessage() {
        recentMessageListener?.remove()
    }
    
}
