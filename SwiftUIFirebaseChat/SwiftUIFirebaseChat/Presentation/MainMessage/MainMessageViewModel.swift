//
//  MainMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

import Firebase
import FirebaseFirestoreSwift

final class MainMessageViewModel: ObservableObject {
    @Published var recentMessages: [RecentMessage] = []
    @Published var users: [ChatUser] = []
    
    @Published var chatUser: ChatUser?
    
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false

    private var documentListener: ListenerRegistration?

    func fetch() {
        fetchAllUser()
        fetchCurrentUser()
    }
    
    func activeFirebaseListener() {
        activeRecentMessagesListener()
    }
    
    func removeFirebaseListener() {
        documentListener?.remove()
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        do {
            try FirebaseManager.shared.auth.signOut()
        } catch {
            print(error)
        }
    }
    
    func deleteChat(indexSet: IndexSet) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        let toId = recentMessages[indexSet.first ?? .zero].toId
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(uid)
            .collection(toId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Failed to get \(error)")
                    return
                }
                querySnapshot?.documents.forEach({ snapshot in
                    FirebaseManager.shared.firestore
                        .collection(FirebaseConstants.messages)
                        .document(uid)
                        .collection(toId)
                        .document(snapshot.documentID)
                        .delete() { error in
                            if let error = error {
                                print("Failed to delete \(error)")
                                return
                            }
                            print("Success to Delete Chat Log")
                        }
                })
                FirebaseManager.shared.firestore
                    .collection(FirebaseConstants.recentMessages)
                    .document(uid)
                    .collection(FirebaseConstants.messages)
                    .document(toId)
                    .delete() { error in
                        if let error = error {
                            print("Failed to delete \(error)")
                            return
                        }
                        print("Success to Delete Recent Message ")
                        self.recentMessages.remove(atOffsets: indexSet)
                    }
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
    
    func activeRecentMessagesListener() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        documentListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    switch change.type {
                    case .added, .modified:
                        print("add..")
                        let docId = change.document.documentID
                                       
                                       if let index = self.recentMessages.firstIndex(where: { recentMessage in
                                           return recentMessage.id == docId
                                       }) {
                                           self.recentMessages.remove(at: index)
                                       }
                        if let rm = try? change.document.data(as: RecentMessage.self) {
                            self.recentMessages.append(rm)
                            self.recentMessages.sort()
                        }
                    case .removed:
                        return
                    }
                }
            }
    }
    
}
