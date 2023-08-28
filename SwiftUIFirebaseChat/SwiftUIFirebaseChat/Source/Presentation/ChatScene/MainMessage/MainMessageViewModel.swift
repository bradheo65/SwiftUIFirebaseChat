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
    private let fetchAllUserUseCase: FetchAllUserUseCaseProtocol
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol
    private let startRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol
    private let stopRecentMessageListenerUseCase: StopRecentMessageListenerUseCaseProtocol
    
    init(
        logoutUseCase: LogoutUseCaseProtocol,
        deleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol,
        fetchAllUserUseCase: FetchAllUserUseCaseProtocol,
        fetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol,
        startRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol,
        stopRecentMessageListenerUseCase: StopRecentMessageListenerUseCaseProtocol
    ) {
        self.logoutUseCase = logoutUseCase
        self.deleteRecentMessageUseCase = deleteRecentMessageUseCase
        self.fetchAllUserUseCase = fetchAllUserUseCase
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.startRecentMessageListenerUseCase = startRecentMessageListenerUseCase
        self.stopRecentMessageListenerUseCase = stopRecentMessageListenerUseCase
    }
    
    @MainActor func fetchAllUser() {
        fetchFirebaseAllUser()
    }
    
    @MainActor func fetchCurrentUser() {
        fetchFirebaseCurrentUser()
    }
    
    func addRecentMessageListener() {
        activeFirebaseRecentMessagesListener()
    }
    
    func removeRecentMessageListener() {
        removeFirebaseRecentMessageListener()
    }
    
    @MainActor
    func handleLogout() {
        logoutFirebaseCurrentUser()
    }
    
    @MainActor
    func deleteRecentChatMessage(indexSet: IndexSet) {
        deleteFirebaseRecentMessage(indexSet: indexSet)
    }
    
}

extension MainMessageViewModel {
    
    @MainActor
    private func fetchFirebaseAllUser() {
        Task {
            do {
                let chatUserList = try await fetchAllUserUseCase.excute()
                
                self.users = chatUserList
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    private func fetchFirebaseCurrentUser() {
        Task {
            do {
                let chatUser = try await fetchCurrentUserUseCase.excute()
                
                self.currentUser = chatUser
            } catch {
                print(error)
            }
        }
    }
    
    private func activeFirebaseRecentMessagesListener() {
        startRecentMessageListenerUseCase.excute { result in
            switch result {
            case .success(let documentChange):
                self.recentMessages = documentChange
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func removeFirebaseRecentMessageListener() {
        stopRecentMessageListenerUseCase.excute()
    }
    
    private func logoutFirebaseCurrentUser() {
        do {
            let logoutResultMessage = try logoutUseCase.excute()
            
            print(logoutResultMessage)
            self.isUserCurrentlyLoggedOut.toggle()
        } catch {
            print(error)
        }
    }
    
    @MainActor
    private func deleteFirebaseRecentMessage(indexSet: IndexSet) {
        guard let firestIndex = indexSet.first else {
            print("Fail to Load first data")
            return
        }
        let toId = recentMessages[firestIndex].toId
        
        Task {
            do {
                let deleteMessageResultMessage = try await deleteRecentMessageUseCase.execute(toId: toId)
                
                print(deleteMessageResultMessage)
                self.recentMessages.remove(atOffsets: indexSet)
            } catch {
                print(error)
            }
        }
    }
    
}
