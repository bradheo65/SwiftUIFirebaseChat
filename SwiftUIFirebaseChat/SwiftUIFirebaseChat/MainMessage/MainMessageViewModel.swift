//
//  MainMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class MainMessageViewModel: ObservableObject {
    @Published var recentMessages: [RecentMessage] = []
    @Published var users: [ChatUser] = []
    
    @Published var chatUser: ChatUser?
    
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        fetchAllUser()
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        do {
            try FirebaseManager.shared.auth.signOut()
        } catch {
            print(error)
        }
    }
}

extension MainMessageViewModel {
    
    private func fetchAllUser() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    do {
                        let user = try snapshot.data(as: ChatUser.self)
                        
                        if user.id != FirebaseManager.shared.auth.currentUser?.uid {
                            self.users.append(user)
                        }
                    } catch {
                        print(error)
                    }
                })
                
                self.errorMessage = "Fetched users successfully"
            }
    }
    
    private func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        errorMessage = "Fetching current user \(uid)"
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user \(error)"
                    print("Failed to fetch current user:", error)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No data found"
                    return
                }
                
                self.errorMessage = "Data \(data.description)"
                
                do {
                    let chatUser = try snapshot?.data(as: ChatUser.self)
                    
                    self.chatUser = chatUser
                    FirebaseManager.shared.currentUser = self.chatUser
                } catch {
                    print(error)
                }
            }
    }
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        print(error)
                    }
                })
            }
    }
    
}
