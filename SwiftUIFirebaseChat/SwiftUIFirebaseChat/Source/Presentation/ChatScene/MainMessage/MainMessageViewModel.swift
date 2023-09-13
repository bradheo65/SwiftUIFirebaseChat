//
//  MainMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class MainMessageViewModel: ObservableObject {
    @Published var chatRoom: [ChatRoom] = []
    
    @Published var currentUser: ChatUser?
    
    @Published var errorMessage = ""
    
    @Published var isUserCurrentlyLoggedOut = false

    private let logoutUseCase: LogoutUseCaseProtocol
    private let deleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol
    private let startRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol
    private let stopRecentMessageListenerUseCase: StopRecentMessageListenerUseCaseProtocol
    
    init(
        logoutUseCase: LogoutUseCaseProtocol,
        deleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol,
        fetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol,
        startRecentMessageListenerUseCase: StartRecentMessageListenerUseCaseProtocol,
        stopRecentMessageListenerUseCase: StopRecentMessageListenerUseCaseProtocol
    ) {
        self.logoutUseCase = logoutUseCase
        self.deleteRecentMessageUseCase = deleteRecentMessageUseCase
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.startRecentMessageListenerUseCase = startRecentMessageListenerUseCase
        self.stopRecentMessageListenerUseCase = stopRecentMessageListenerUseCase
    }
    
    /**
    현재 로그인한 사용자 정보를 가져오는 함수
     
     가져온 정보는 'currentUser' 프로퍼티에 저장
     
     - Throws: 'fetchCurrentUserUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    func fetchCurrentUser() async {
        do {
            let chatUser = try await fetchCurrentUserUseCase.excute()
            
            DispatchQueue.main.async {
                self.currentUser = chatUser
            }
        } catch {
            print(error)
        }
    }
    
    /**
    최근 메시지 리스너 활성화하는 함수
     
     새로운 메시가 도착하면 해당 메시지 정보를 가져와 'chatRoomList'에 업데이트
     
     - Throws: 'startRecentMessageListenerUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    func addRecentMessageListener() {
        startRecentMessageListenerUseCase.excute { result in
            switch result {
            case .success(let list):
                self.updateChatRoom(list: list)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
    최근 메시지 리스너 비활성화하는 함수
     */
    func removeRecentMessageListener() {
        stopRecentMessageListenerUseCase.excute()
    }
    
    /**
    현재 사용자 로그아웃을 처리하는 함수
     
     로그아웃 이후 'isUserCurrentlyLoggedOut' 상태 업데이트
     
     - Throws: 'logoutUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    func handleLogout() {
        do {
            let logoutResultMessage = try logoutUseCase.excute()
            print(logoutResultMessage)
            DispatchQueue.main.async {
                self.isUserCurrentlyLoggedOut.toggle()
            }
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
    func deleteRecentChatMessage(indexSet: IndexSet) {
        guard let firstIndex = indexSet.first else {
            print("Fail to Load first data")
            return
        }
        let firstChatRoom = chatRoom[firstIndex]

        if let index = chatRoom.firstIndex(of: firstChatRoom) {
            chatRoom.remove(at: index)
        } else {
            chatRoom.remove(atOffsets: indexSet)
        }
        
        Task {
            do {
                let deleteMessageResultMessage = try await deleteRecentMessageUseCase.execute(id: firstChatRoom.id, toId: firstChatRoom.toId)
                print(deleteMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
}

extension MainMessageViewModel {
    private func updateChatRoom(list: ChatRoom) {
        if chatRoom.isEmpty {
            chatRoom.append(list)
        } else if let index = chatRoom.firstIndex(where: { $0.id == list.id }) {
            chatRoom[index] = list // 이미 존재하는 경우 해당 객체를 업데이트
        } else {
            chatRoom.append(list) // 존재하지 않는 경우 추가
        }
        chatRoom.sort(by: <)
    }
}
