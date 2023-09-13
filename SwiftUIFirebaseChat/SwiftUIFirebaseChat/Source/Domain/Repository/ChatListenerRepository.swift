//
//  ChatListenerRepository.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/21.
//

import Foundation

import RealmSwift

final class ChatListenerRepository: ChatListenerRepositoryProtocol {
    
    private let firebaseSerivce: FirebaseChatListenerProtocol
    private let dataSource: RealmDataSourceProtocol

    private var chetMessageListenerToken: NotificationToken?
    private var chatRoomListenerToken: NotificationToken?

    init(firebaseSerivce: FirebaseChatListenerProtocol, dataSource: RealmDataSourceProtocol) {
        self.firebaseSerivce = firebaseSerivce
        self.dataSource = dataSource
    }
     
    func fetchChatMessage(chatUser: ChatUser, dateOffset: Int, completion: @escaping (ChatLog) -> Void) {
        let filterQuery = "(fromId = %@ OR toId == %@) AND (timestamp >= %@ AND timestamp < %@)"
        let chatLogDTO = dataSource.read(ChatLogDTO.self)
        
        // 현재 날짜 가져오기
        let currentDate = Date()

        // 어제의 날짜 계산
        var currentDateOffset = -dateOffset
        
        var today = Calendar.current.date(byAdding: .day, value: currentDateOffset, to: currentDate)!
        var yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        while currentDateOffset <= 0 {
            let filterChatLog = chatLogDTO.filter(
                filterQuery,
                chatUser.uid, chatUser.uid, yesterday, today
            )

            if filterChatLog.isEmpty == false {
                filterChatLog.forEach { log in
                    completion(log.toDomain())
                }
                break
            }
            
            // 데이터를 찾지 못한 경우 다음 날짜로 이동
            currentDateOffset -= 1
            today = Calendar.current.date(byAdding: .day, value: currentDateOffset, to: currentDate)!
            yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            
            if currentDateOffset == -10 {
                break
            }
        }
    }
    /**
     채팅 메시지를 감지하여 처리하는 함수

     이 함수는 주어진 대화 상대의 ChatUser 정보를 기반으로 Firebase에서 채팅 메시지를 감지하고, 새로운 메시지가 추가되었을 경우 해당 메시지를 처리합니다.

     - Parameters:
       - chatUser: 대화 상대의 ChatUser 정보
       - completion: 메시지 처리 결과를 담은 Result<ChatMessage, Error>를 반환하는 클로저

     - Note: Firebase에서 채팅 메시지를 감지하여 새로운 메시지가 추가되었을 경우, 해당 메시지를 처리하고 ChatLog 객체를 Realm에 저장합니다.
     */
    func startRealmChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatLog, Error>) -> Void) {
        let chatLogDTO = dataSource.read(ChatLogDTO.self)
        
        self.chetMessageListenerToken = chatLogDTO.observe { changes in
            switch changes {
            case .initial(_):
                return
            case .update(let chatLogDTO, _, let insertions, _):
                if insertions.count > 0 {
                    completion(.success((chatLogDTO.last?.toDomain())!))
                }
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
    
    func startFirebaseChatMessageListener(chatUser: ChatUser) {
        firebaseSerivce.listenForChatMessage(chatUser: chatUser) { result in
            switch result {
            case .success(let documentChange):
                if documentChange.type == .added {
                    do {
                        let chatMessage = try documentChange.document.data(as: ChatMessageResponseDTO.self).toDomain()
                                       
                        let id = self.generateChatLogId(fromId: chatMessage.fromId, toId: chatMessage.toId)
                        let chatLogDTO = self.createChatLog(from: chatMessage, with: id)
                        
                        self.saveChatLog(chatLogDTO, with: id)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func stopChatMessageListener() {
        firebaseSerivce.stopListenForChatMessage()
        chetMessageListenerToken?.invalidate()
    }
    
    /**
     최근 메시지를 감지하여 처리하는 함수
     
     이 함수는 Firebase에서 최근 메시지를 감지하고, 메시지의 추가 또는 수정 사항이 발생한 경우 해당 메시지를 처리합니다.
     
     - Parameters:
       - completion: 최근 메시지 처리 결과를 담은 Result<[ChatRoomResponseDTO], Error>를 반환하는 클로저
     
     - Note: Firebase에서 최근 메시지를 감지하여 메시지의 추가 또는 수정 사항이 발생한 경우, 해당 메시지를 처리하고 ChatRoom 객체를 생성하여 ChatListLog를 만듭니다.
     */
    func startRealmChatRoomListener(completion: @escaping (Result<ChatRoom, Error>) -> Void) {        
        let chatRoomDTO = dataSource.read(ChatRoomDTO.self)

        self.chatRoomListenerToken = chatRoomDTO.observe { changes in
            switch changes {
            case .initial(let chatRoomDTO):
                chatRoomDTO.forEach { list in
                    completion(.success(list.toDomain()))
                }
            case .update(let chatRoomDTO, _, let insertions, let modifer):
                if insertions.count > 0 {
                    completion(.success(chatRoomDTO[insertions.first!].toDomain()))
                }
                if modifer.count > 0 {
                    completion(.success(chatRoomDTO[modifer.first!].toDomain()))
                }
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
    
    func startFirebaseChatRoomListener() {
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                guard let chatRoomResponseDTO = try? documentChange.document.data(as: ChatRoomResponseDTO.self).toDomain() else {
                    return
                }
                switch documentChange.type {
                case .added:
                    let filterQuery = "(toId == %@ AND fromId == %@) OR (toId == %@ AND fromId == %@)"
                    let filterChatRoomDTO = self.dataSource.read(ChatRoomDTO.self).filter(
                        filterQuery, chatRoomResponseDTO.toId, chatRoomResponseDTO.fromId, chatRoomResponseDTO.fromId, chatRoomResponseDTO.toId
                    )
                    
                    // 이미 저장되어 있다면 저장하지 않습니다.
                    if filterChatRoomDTO.isEmpty {
                        self.createChatListLog(from: chatRoomResponseDTO, id: nil)
                    }
                case .modified:
                    let id = self.generateChatLogId(fromId: chatRoomResponseDTO.fromId, toId: chatRoomResponseDTO.toId)
                    self.createChatListLog(from: chatRoomResponseDTO, id: id)
                case .removed:
                    return
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func stopRecentMessageListener() {
        firebaseSerivce.stopListenForRecentMessage()
        chatRoomListenerToken?.invalidate()
    }
    
}

extension ChatListenerRepository {
    
    /**
     채팅 메시지로부터 고유한 채팅 로그 ID를 생성하는 함수
     
     이 함수는 주어진 채팅 메시지를 기반으로 고유한 채팅 로그 ID를 생성하여 반환합니다.
     만약 해당 채팅 메시지의 대화 상대방과의 채팅 로그가 이미 존재한다면 그 ID를 반환하고,
     그렇지 않은 경우 대화 상대방의 ID를 사용하여 새로운 채팅 로그 ID를 생성합니다.
     
     - Parameters:
       - fromId: 채팅 보낸 유저의 ID
       - toId: 채팅 받는 유저의 ID
     
     - Returns: 생성된 채팅 로그 ID
     */
    private func generateChatLogId(fromId: String, toId: String) -> String {
        let filterQuery = "(toId == %@ AND fromId == %@) OR (toId == %@ AND fromId == %@)"
        let filterChatList = dataSource.read(ChatRoomDTO.self).filter(filterQuery, toId, fromId, fromId, toId)
        
        let id = filterChatList.first?.id

        return id ?? UUID().uuidString
    }
    
    private func createChatLog(from chatMessageResponse: ChatMessageResponse, with id: String) -> ChatLogDTO {
        let chatLogDTO = ChatLogDTO()
        
        chatLogDTO.id = id
        chatLogDTO.fromId = chatMessageResponse.fromId
        chatLogDTO.toId = chatMessageResponse.toId
        chatLogDTO.text = chatMessageResponse.text
        chatLogDTO.imageUrl = chatMessageResponse.imageUrl
        chatLogDTO.videoUrl = chatMessageResponse.videoUrl
        chatLogDTO.imageWidth = chatMessageResponse.imageWidth
        chatLogDTO.imageHeight = chatMessageResponse.imageHeight
        chatLogDTO.fileType = chatMessageResponse.fileType
        chatLogDTO.fileUrl = chatMessageResponse.fileUrl
        chatLogDTO.timestamp = chatMessageResponse.timestamp

        return chatLogDTO
    }
    
    private func saveChatLog(_ chatLog: ChatLogDTO, with id: String) {
        let filterQuery = "id == %@"
        let filterChatLogDTO = dataSource.read(ChatLogDTO.self).filter(filterQuery, id)
        
        // 중복된 ChatLog가 없을 경우 ChatLog를 Realm에 추가합니다.
        if filterChatLogDTO.isEmpty {
            dataSource.add(chatLog)
        } else if let data = filterChatLogDTO.last?.timestamp {
            // 이미 존재하는 ChatLog 중 가장 마지막 메시지의 타임스탬프와 비교하여 최신 메시지인 경우 추가합니다.
            if data < chatLog.timestamp {
                dataSource.add(chatLog)
            }
        }
    }
    
    private func createChatListLog(from chatRoomResponse: ChatRoomResponse, id: String?) {
        let chatList = ChatRoomDTO()

        // id가 제공되지 않으면 UUID를 사용하여 고유한 id를 생성
        chatList.id = id ?? UUID().uuidString
        chatList.text = chatRoomResponse.text
        chatList.username = chatRoomResponse.username
        chatList.email = chatRoomResponse.email
        
        // fromId와 toId를 설정 - 상대방 메세지만 보냈을 경우, id 중복 방지
        if chatRoomResponse.id == chatRoomResponse.fromId {
            chatList.fromId = chatRoomResponse.toId
            chatList.toId = chatRoomResponse.fromId
        } else {
            chatList.fromId = chatRoomResponse.fromId
            chatList.toId = chatRoomResponse.toId
        }
        
        chatList.profileImageURL = chatRoomResponse.profileImageURL
        chatList.timestamp = chatRoomResponse.timestamp
        
        dataSource.create(ChatRoomDTO.self, value: chatList)
    }
    
}
