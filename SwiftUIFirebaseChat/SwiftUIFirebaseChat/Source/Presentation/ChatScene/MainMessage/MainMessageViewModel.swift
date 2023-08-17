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

    private let logoutUseCase: LogoutUseCaseProtocol
    private let deleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol
    private let getAllUserUseCase: GetAllUserUseCaseProtocol
    private let getCurrentUserUseCase: GetCurrentUserUseCaseProtocol
    private let addRecentMessageListenerUseCase: AddRecentMessageListenerUseCaseProtocol
    private let removeRecentMessageListenerUseCase: RemoveRecentMessageListenerUseCaseProtocol
    
    init(
        logoutUseCase: LogoutUseCaseProtocol,
        deleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol,
        getAllUserUseCase: GetAllUserUseCaseProtocol,
        getCurrentUserUseCase: GetCurrentUserUseCaseProtocol,
        addRecentMessageListenerUseCase: AddRecentMessageListenerUseCaseProtocol,
        removeRecentMessageListenerUseCase: RemoveRecentMessageListenerUseCaseProtocol
    ) {
        self.logoutUseCase = logoutUseCase
        self.deleteRecentMessageUseCase = deleteRecentMessageUseCase
        self.getAllUserUseCase = getAllUserUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.addRecentMessageListenerUseCase = addRecentMessageListenerUseCase
        self.removeRecentMessageListenerUseCase = removeRecentMessageListenerUseCase
    }
    
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
    
    func deleteRecentChatMessage(indexSet: IndexSet) {
        deleteFirebaseRecentMessage(indexSet: indexSet)
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
        addRecentMessageListenerUseCase.excute { result in
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
    
    private func deleteFirebaseRecentMessage(indexSet: IndexSet) {
        guard let firestIndex = indexSet.first else {
            print("Fail to Load first data")
            return
        }
        let toId = recentMessages[firestIndex].toId
        
        deleteRecentMessageUseCase.excute(toId: toId) { result in
            switch result {
            case .success(let message):
                print(message)
                self.recentMessages.remove(atOffsets: indexSet)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
