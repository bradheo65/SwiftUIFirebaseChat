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
    
    private override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
