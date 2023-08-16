//
//  FirebaseService.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

import Firebase
import FirebaseStorage

final class FirebaseService: NSObject {
    
    private let auth: Auth
    private let storage: Storage
    private let firestore: Firestore
    
    private var timeStamp: Timestamp {
        get {
            return Timestamp()
        }
    }
    private var chatMessageListener: ListenerRegistration?
    private var recentMessageListener: ListenerRegistration?
    
    private var currentUser: ChatUser?
    
    static let shared = FirebaseService()
    
    private override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
 
extension FirebaseService {
        
    func getAllUsers(completion: @escaping (Result<ChatUser, Error>) -> Void) {
        firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    do {
                        let user = try snapshot.data(as: ChatUser.self)
                        
                        if user.id != self.auth.currentUser?.uid {
                            completion(.success(user))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                })
            }
    }
    
    func getCurrentUser(completion: @escaping (Result<ChatUser?, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user:", error)
                    return
                }
                
                do {
                    let currentUser = try snapshot?.data(as: ChatUser.self)

                    self.currentUser = currentUser
                    completion(.success(currentUser))
                } catch let error {
                    print(error)
                }
            }
    }
    
}

extension FirebaseService {
    
    func sendTextMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Text.text: text,
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
        
        sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendImageMessage(imageURL: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Image.url: imageURL.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
        
        sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendVideoMessage(imageUrl: URL, videoUrl: URL, image: UIImage, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        let width = Float(image.size.width)
        let height = Float(image.size.height)
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.Image.url: imageUrl.absoluteString,
            FirebaseConstants.Video.url: videoUrl.absoluteString,
            FirebaseConstants.Image.width: CGFloat(200),
            FirebaseConstants.Image.height: CGFloat(height / width * 200),
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
        
        sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendFileMessage(fileInfo: FileInfo, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        let messageData = [
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.File.url: fileInfo.url.absoluteString,
            FirebaseConstants.File.name: fileInfo.name,
            FirebaseConstants.File.type: fileInfo.contentType,
            FirebaseConstants.File.size: fileInfo.size,
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
    
        sendMessage(fromId: currentUser.uid, toId: chatUser.uid, messageData: messageData) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
       
    func sendRecentMessage(text: String, chatUser: ChatUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = currentUser else {
            print("Send Message Error no Current User Data")
            return
        }
        
        let document = firestore
            .collection(FirebaseConstants.recentMessages)
            .document(currentUser.uid)
            .collection(FirebaseConstants.messages)
            .document(chatUser.uid)
        
        let data = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.profileImageURL: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email,
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        let recipientRecentMessageDictionary = [
            FirebaseConstants.Text.text: text,
            FirebaseConstants.fromId: currentUser.uid,
            FirebaseConstants.toId: chatUser.uid,
            FirebaseConstants.profileImageURL: currentUser.profileImageURL,
            FirebaseConstants.email: currentUser.email,
            FirebaseConstants.timestamp: timeStamp
        ] as [String : Any]
        
        firestore
            .collection(FirebaseConstants.recentMessages)
            .document(chatUser.uid)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("Success to send recent message"))
            }
    }
    
    private func sendMessage(fromId: String, toId: String, messageData: [String: Any], compltion: @escaping (Result<String, Error>) -> Void) {
        let document = firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let recipientMessageDocument = firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        document.setData(messageData) { error in
            if let error = error {
                compltion(.failure(error))
                return
            }
            recipientMessageDocument.setData(messageData) { error in
                if let error = error {
                    compltion(.failure(error))
                    return
                }
                compltion(.success("Successfully saved to user sending message"))
            }
        }
    }
    
}

extension FirebaseService {
    
    func uploadImage(image: UIImage, compltion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storage.reference()
            .child(FirebaseConstants.Storage.messageImages)
            .child(UUID().uuidString)
        
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            ref.putData(uploadData) { metadata, error in
                if let error = error {
                    print(error)
                    compltion(.failure(error))
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print(error)
                        compltion(.failure(error))
                        return
                    }
                    print("Successfully stored image with url \(url?.absoluteString ?? "")")
                    
                    guard let url = url else {
                        return
                    }
                    compltion(.success(url))
                }
            }
        }
    }
    
    func uploadVideo(url: URL, compltion: @escaping (Result<URL, Error>) -> Void) {
        let videoRef = storage.reference()
            .child(FirebaseConstants.Storage.messageVideos)
            .child(UUID().uuidString)
        
        do {
            let data = try Data(contentsOf: url)
            
            if let uploadData = data as Data? {
                let metaData = StorageMetadata()
                metaData.contentType = "video/mp4"
                
                let uploadTask = videoRef.putData(uploadData, metadata: metaData) { metadata, error in
                    if let error = error {
                        print(error.localizedDescription)
                        compltion(.failure(error))
                        return
                    }
                    
                    videoRef.downloadURL { url, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        guard let url = url else {
                            return
                        }
                        print("Successfully stored video with url \(url.absoluteString)")
                        compltion(.success(url))
                    }
                }
                    
                uploadTask.observe(.progress) { snapshot in
                    print(snapshot.progress?.completedUnitCount as Any)
                }
                
                uploadTask.observe(.success) { snapshot in
                    print(snapshot.status)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func uploadFile(url: URL, compltion: @escaping (Result<FileInfo, Error>) -> Void) {
        let fileRef = storage.reference()
            .child(FirebaseConstants.Storage.messageFiles)
            .child(url.deletingPathExtension().lastPathComponent)
        
        fileRef.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print(error.localizedDescription)
                compltion(.failure(error))
                return
            }
            
            print("uploadFile Success")
            
            fileRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    compltion(.failure(error))
                    return
                }
                
                guard let url = url else {
                    return
                }
                fileRef.getMetadata { meta, error in
                    if let error = error {
                        print(error.localizedDescription)
                        compltion(.failure(error))
                        return
                    }
                    guard let contentType = meta?.contentType else {
                        return
                    }
                    let fileSize = meta?.size ?? .zero
                    
                    let size = Float(fileSize) / 1000000
                    
                    print("Successfully stored File with url \(url.absoluteString)")
                    
                    let fileInfo = FileInfo(
                        url: url,
                        name: url.deletingPathExtension().lastPathComponent,
                        contentType: contentType,
                        size: String(format: "%.2f", size)
                    )
                    compltion(.success(fileInfo))
                }
            }
        }
    }
    
    func uploadAccountInfo(email: String, profileImageUrl: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageURL: profileImageUrl.absoluteString
        ]
        
        firestore.collection(FirebaseConstants.users)
            .document(uid)
            .setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("Success upload data to Firestore"))
            }
    }
    
}

extension FirebaseService {
    
    func handleCreateAccount(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(result?.user.email ?? ""))
        }
    }
    
    func handleLogin(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success("Success to Login \(result?.user.uid ?? "")"))
        }
    }
    
    func handleLogout(completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try auth.signOut()
            completion(.success("Success to Logout"))
        } catch let error {
            completion(.failure(error))
        }
    }
    
}

extension FirebaseService {
    
    func addChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
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
    
    func addRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
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
    
    func removeChatMessageListener() {
        chatMessageListener?.remove()
    }
    
    func removeRecentMessageListener() {
        recentMessageListener?.remove()
    }
    
}

extension FirebaseService {
    
    func deleteChatMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        firestore
            .collection(FirebaseConstants.messages)
            .document(uid)
            .collection(toId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                querySnapshot?.documents.forEach({ snapshot in
                    self.firestore
                        .collection(FirebaseConstants.messages)
                        .document(uid)
                        .collection(toId)
                        .document(snapshot.documentID)
                        .delete() { error in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                        }
                })
                completion(.success("Success to Delete Chat Log"))
            }
    }
    
    func deleteRecentMessage(toId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        self.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
            .delete() { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("Success to Delete Recent Message"))
            }
    }
    
}
