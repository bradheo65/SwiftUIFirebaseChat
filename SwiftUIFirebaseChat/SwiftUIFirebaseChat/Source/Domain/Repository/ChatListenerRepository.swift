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

    private var chetMessageToken: NotificationToken?
    private var recentChatListToken: NotificationToken?

    init(firebaseSerivce: FirebaseChatListenerProtocol, dataSource: RealmDataSourceProtocol) {
        self.firebaseSerivce = firebaseSerivce
        self.dataSource = dataSource
    }
    
    /**
     채팅 메시지를 감지하여 처리하는 함수

     이 함수는 주어진 대화 상대의 ChatUser 정보를 기반으로 Firebase에서 채팅 메시지를 감지하고, 새로운 메시지가 추가되었을 경우 해당 메시지를 처리합니다.

     - Parameters:
       - chatUser: 대화 상대의 ChatUser 정보
       - completion: 메시지 처리 결과를 담은 Result<ChatMessage, Error>를 반환하는 클로저

     - Note: Firebase에서 채팅 메시지를 감지하여 새로운 메시지가 추가되었을 경우, 해당 메시지를 처리하고 ChatLog 객체를 Realm에 저장합니다.
     */
    func startChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatLog, Error>) -> Void) {
        startChatMessageListener(chatUser: chatUser)
        
        let chatLogsDTO = dataSource.read(ChatLogDTO.self)
        
        self.chetMessageToken = chatLogsDTO.observe { changes in
            switch changes {
            case .initial(_):
                let filterChatLogs = chatLogsDTO.filter("fromId = %@ OR toId == %@", chatUser.uid, chatUser.uid)
                
                filterChatLogs.forEach { logs in
                    completion(.success(logs.toDomain()))
                }
            case .update(let collectionType, _, let insertions, _):
                if insertions.count > 0 {
                    completion(.success((Array(collectionType).last?.toDomain())!))
                }
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
    
    func startChatMessageListener(chatUser: ChatUser) {
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
    }
    
    /**
     최근 메시지를 감지하여 처리하는 함수
     
     이 함수는 Firebase에서 최근 메시지를 감지하고, 메시지의 추가 또는 수정 사항이 발생한 경우 해당 메시지를 처리합니다.
     
     - Parameters:
       - completion: 최근 메시지 처리 결과를 담은 Result<[ChatRoomResponseDTO], Error>를 반환하는 클로저
     
     - Note: Firebase에서 최근 메시지를 감지하여 메시지의 추가 또는 수정 사항이 발생한 경우, 해당 메시지를 처리하고 ChatRoom 객체를 생성하여 ChatListLog를 만듭니다.
     */
    func startRecentMessageListener(completion: @escaping (Result<ChatList, Error>) -> Void) {
        firebaseRecentMessageListener()
        
        let chatLogs = dataSource.read(ChatList.self)

        self.recentChatListToken = chatLogs.observe { changes in
            switch changes {
            case .initial(let collectionType):
                collectionType.forEach { list in
                    completion(.success(list))
                }
            case .update(let collectionType, _, let insertions, let modifer):
                if insertions.count > 0 {
                    completion(.success(collectionType[insertions.first!]))
                }
                if modifer.count > 0 {
                    completion(.success(collectionType[modifer.first!]))
                }
            case .error(let error):
                completion(.failure(error))
            }
        }
    }
    
    func firebaseRecentMessageListener() {
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                guard let chatRoom = try? documentChange.document.data(as: ChatRoomResponseDTO.self).toDomain()  else {
                    return
                }
                switch documentChange.type {
                case .added:
                    let filterQuery = "(toId == %@ AND fromId == %@) OR (toId == %@ AND fromId == %@)"
                    let filterChatList = self.dataSource.read(ChatList.self).filter(filterQuery, chatRoom.toId, chatRoom.fromId, chatRoom.fromId, chatRoom.toId)
                    
                    // 이미 저장되어 있다면 저장하지 않습니다.
                    if filterChatList.isEmpty {
                        self.createChatListLog(from: chatRoom, id: nil)
                    }
                case .modified:
                    let id = self.generateChatLogId(fromId: chatRoom.fromId, toId: chatRoom.toId)
                    self.createChatListLog(from: chatRoom, id: id)
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
        recentChatListToken?.invalidate()
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
        let filterChatList =  dataSource.read(ChatList.self).filter(filterQuery, toId, fromId, fromId, toId)
        
        let id = filterChatList.first?.id

        return id ?? UUID().uuidString
    }
    
    private func createChatLog(from chatMessage: ChatMessage, with id: String) -> ChatLogDTO {
        let chatLog = ChatLogDTO()
        
        chatLog.id = id
        chatLog.fromId = chatMessage.fromId
        chatLog.toId = chatMessage.toId
        chatLog.text = chatMessage.text
        chatLog.imageUrl = chatMessage.imageUrl
        chatLog.videoUrl = chatMessage.videoUrl
        chatLog.imageWidth = chatMessage.imageWidth
        chatLog.imageHeight = chatMessage.imageHeight
        chatLog.fileTitle = chatMessage.fileTitle
        chatLog.fileSizes = chatMessage.fileSizes
        chatLog.fileType = chatMessage.fileType
        chatLog.fileUrl = chatMessage.fileUrl
        chatLog.timestamp = chatMessage.timestamp

        return chatLog
    }
    
    private func saveChatLog(_ chatLog: ChatLogDTO, with id: String) {
        let filterQuery = "id == %@"
        let filterChatLog = dataSource.read(ChatLogDTO.self).filter(filterQuery, id)
        
        // 중복된 ChatLog가 없을 경우 ChatLog를 Realm에 추가합니다.
        if filterChatLog.isEmpty {
            dataSource.add(chatLog)
        } else if let data = filterChatLog.last?.timestamp {
            // 이미 존재하는 ChatLog 중 가장 마지막 메시지의 타임스탬프와 비교하여 최신 메시지인 경우 추가합니다.
            if data < chatLog.timestamp {
                dataSource.add(chatLog)
            }
        }
    }
    
    private func createChatListLog(from chatRoom: ChatRoom, id: String?) {
        let chatList = ChatList()

        // id가 제공되지 않으면 UUID를 사용하여 고유한 id를 생성
        chatList.id = id ?? UUID().uuidString
        chatList.text = chatRoom.text
        chatList.username = chatRoom.username
        chatList.email = chatRoom.email
        
        // fromId와 toId를 설정 - 상대방 메세지만 보냈을 경우, id 중복 방지
        if chatRoom.id == chatRoom.fromId {
            chatList.fromId = chatRoom.toId
            chatList.toId = chatRoom.fromId
        } else {
            chatList.fromId = chatRoom.fromId
            chatList.toId = chatRoom.toId
        }
        
        chatList.profileImageURL = chatRoom.profileImageURL
        chatList.timestamp = chatRoom.timestamp
        
        dataSource.create(ChatList.self, value: chatList)
    }
    
}
