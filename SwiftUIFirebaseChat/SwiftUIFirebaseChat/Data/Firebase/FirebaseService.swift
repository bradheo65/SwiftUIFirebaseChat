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
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var timeStamp: Timestamp {
        get {
            return Timestamp()
        }
    }

    var firestoreListener: ListenerRegistration?
    private var recentMessageListener: ListenerRegistration?
        
    var currentUser: ChatUser?
    
    static let shared = FirebaseService()

    private override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
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
    
    func handleSendMessage(fromDocument: DocumentReference, toDocument: DocumentReference, messageData: [String: Any], compltion: @escaping () -> Void) {
        
        fromDocument.setData(messageData) { error in
            if let error = error {
                print("Failed to save message into Firestore: \(error)")
                return
            }
            
            print("Successfully saved current user sending message")
        }
        
        toDocument.setData(messageData) { error in
            if let error = error {
                print("Failed to save message into Firestore: \(error)")
                return
            }
            compltion()
            print("Successfully saved to user sending message")
        }
    }
    
    func uploadImage(image: UIImage, storageReference: StorageReference, compltion: @escaping (Result<URL, Error>) -> Void) {
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            storageReference.putData(uploadData) { metadata, error in
                if let error = error {
                    print(error)
                    compltion(.failure(error))
                    return
                }
                
                storageReference.downloadURL { url, error in
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
    
    func uploadVideo(url: URL, storageReference: StorageReference, compltion: @escaping (Result<URL, Error>) -> Void) {
        do {
            let data = try Data(contentsOf: url)
            
            if let uploadData = data as Data? {
                let metaData = StorageMetadata()
                metaData.contentType = "video/mp4"
                
                let uploadTask = storageReference.putData(uploadData, metadata: metaData) { metadata, error in
                    if let error = error {
                        print(error.localizedDescription)
                        compltion(.failure(error))
                        return
                    }
                    
                    storageReference.downloadURL { url, error in
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
    
    func uploadFile(url: URL, storageReference: StorageReference, compltion: @escaping (Result<FileInfo, Error>) -> Void) {
        
        storageReference.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print(error.localizedDescription)
                compltion(.failure(error))
                return
            }
            
            print("uploadFile Success")
            
            storageReference.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    compltion(.failure(error))
                    return
                }
                
                guard let url = url else {
                    return
                }
                storageReference.getMetadata { meta, error in
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
    
    func uploadDataToFirestore(documentName: String, data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        firestore.collection(documentName)
            .document(uid)
            .setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success("Success upload data to Firestore"))
            }
    }
    
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
    
    func handleRecentMessageListener(completion: @escaping (Result<DocumentChange, Error>) -> Void) {
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
    
    func handleRemoveRecentMessageListener() {
        recentMessageListener?.remove()
    }
    
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
