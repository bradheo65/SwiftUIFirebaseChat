//
//  FirebaseManager.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/08.
//

import Foundation

import Firebase
import FirebaseStorage

final class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var timeStamp: Timestamp {
        get {
            return Timestamp()
        }
    }

    var firestoreListener: ListenerRegistration?

    static let shared = FirebaseManager()
    
    var currentUser: ChatUser?
    
    private override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
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
            print("Successfully saved current user sending message")
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
                    print(snapshot.progress?.completedUnitCount)
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
    
}
