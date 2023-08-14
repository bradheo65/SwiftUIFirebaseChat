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
    
    @Published var currentUser: ChatUser?
    
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false

    private let getAllUserUseCase = GetAllUsersUseCase()
    private let getCurrentUserUseCase = GetCurrentUserUseCase()
    private let activeRecentMessageListenerUseCase = ActiveRecentMessageListenerUseCase()
    private let removeRecentMessageListenerUseCase = RemoveRecentMessageListenerUseCase()
    private let logoutUseCase = LogoutUseCase()

    func fetchAllUser() {
        fetchFirebaseAllUser()
    }
    
    func fetchCurrentUser() {
        fetchFirebaseCurrentUser()
    }
    
    func addRecentMessageListener() {
        activeFirebaseRecentMessagesListener()
    }
    
    func removeRecentMessageListener() {
        removeFirebaseRecentMessageListener()
    }
    
    func handleLogout() {
        logoutFirebaseCurrentUser()
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
    
    private func fetchFirebaseAllUser() {
        getAllUserUseCase.excute { result in
            switch result {
            case .success(let user):
                self.users.append(user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchFirebaseCurrentUser() {
        getCurrentUserUseCase.excute { result in
            switch result {
            case .success(let currentUser):
                self.currentUser = currentUser
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func activeFirebaseRecentMessagesListener() {
        activeRecentMessageListenerUseCase.excute { result in
            switch result {
            case .success(let documentChange):
                switch documentChange.type {
                case .added, .modified:
                    let docId = documentChange.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    if let rm = try? documentChange.document.data(as: RecentMessage.self) {
                        self.recentMessages.append(rm)
                        self.recentMessages.sort()
                    }
                case .removed:
                    return
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func removeFirebaseRecentMessageListener() {
        removeRecentMessageListenerUseCase.excute()
    }
    
    private func logoutFirebaseCurrentUser() {
        logoutUseCase.excute { result in
            switch result {
            case .success(let message):
                print(message)
                self.isUserCurrentlyLoggedOut.toggle()
            case .failure(let error):
                print(error)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
}
