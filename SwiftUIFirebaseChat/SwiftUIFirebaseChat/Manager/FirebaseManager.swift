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
    
    
}
