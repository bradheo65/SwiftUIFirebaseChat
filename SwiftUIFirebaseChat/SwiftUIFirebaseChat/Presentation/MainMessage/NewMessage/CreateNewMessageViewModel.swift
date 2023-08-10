//
//  CreateNewMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class CreateNewMessageViewModel: ObservableObject {
    @Published var users: [ChatUser] = []
    @Published var errorMessage = ""
    
    init() {
        fetchAllUser()
    }
}

extension CreateNewMessageViewModel {
    
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
    
}
