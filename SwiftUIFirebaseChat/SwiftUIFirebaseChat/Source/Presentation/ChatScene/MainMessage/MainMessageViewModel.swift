//
//  MainMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class MainMessageViewModel: ObservableObject {
    
    @Published var chatRoomList: [ChatList] = []
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
    
    @MainActor
    func fetchAllUser() {
        fetchFirebaseAllUser()
    }
    
    @MainActor
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
    
    @MainActor
    func deleteRecentChatMessage(indexSet: IndexSet) {
        deleteFirebaseRecentMessage(indexSet: indexSet)
    }
    
}

extension MainMessageViewModel {
    
    /**
    모든 사용자 정보를 가져오는 함수
     
     가져온 정보는 'users' 프로퍼티에 저장
     
     - Throws: 'fetchAllUserUseCase.excute()' 메서드가 실패한 경우 에러를 출력
    */
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
    
    /**
    현재 로그인한 사용자 정보를 가져오는 함수
     
     가져온 정보는 'currentUser' 프로퍼티에 저장
     
     - Throws: 'fetchCurrentUserUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
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
    
    /**
    최근 메시지 리스너 활성화하는 함수
     
     새로운 메시가 도착하면 해당 메시지 정보를 가져와 'chatRoomList'에 업데이트
     
     - Throws: 'startRecentMessageListenerUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    private func activeFirebaseRecentMessagesListener() {
        startRecentMessageListenerUseCase.excute { result in
            switch result {
            case .success(let chatRoomList):
                self.chatRoomList = chatRoomList.sorted(by: <)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
    최근 메시지 리스너 비활성화하는 함수
     */
    private func removeFirebaseRecentMessageListener() {
        stopRecentMessageListenerUseCase.excute()
    }
    
    /**
    현재 사용자 로그아웃을 처리하는 함수
     
     로그아웃 이후 'isUserCurrentlyLoggedOut' 상태 업데이트
     
     - Throws: 'logoutUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    private func logoutFirebaseCurrentUser() {
        do {
            let logoutResultMessage = try logoutUseCase.excute()
            
            self.isUserCurrentlyLoggedOut.toggle()
        } catch {
            print(error)
        }
    }
    
    /**
    최근 메세지 삭제하는 함수
     
     선택한 메시지의 'toId'를 사용하여 메세지를 삭제하고, 'chatRoomList'에서도 해당 메세지를 제거
     
     - Parameters:
        - indexSet: 삭제할 메시지의 indexSet
     
     - Throws: 'deleteRecentMessageUseCase.execute(toId: toId)' 메서드가 실패한 경우 에러를 출력
     */
    @MainActor
    private func deleteFirebaseRecentMessage(indexSet: IndexSet) {
        guard let firestIndex = indexSet.first else {
            print("Fail to Load first data")
            return
        }
        let chatRoom = chatRoomList[firestIndex]

        if let index = chatRoomList.firstIndex(of: chatRoom) {
            chatRoomList.remove(at: index)
        } else {
            chatRoomList.remove(atOffsets: indexSet)
        }
        
        Task {
            do {
                let deleteMessageResultMessage = try await deleteRecentMessageUseCase.execute(toId: chatRoom.toId)
                
            } catch {
                print(error)
            }
        }
    }
    
}
