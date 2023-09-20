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
    private var conversationListenerToken: NotificationToken?

    init(firebaseSerivce: FirebaseChatListenerProtocol, dataSource: RealmDataSourceProtocol) {
        self.firebaseSerivce = firebaseSerivce
        self.dataSource = dataSource
    }
    
    func fetchUserChatMessage(chatUser: ChatUser) async throws {
        do {
            let chatMessageResponseDTO = try await firebaseSerivce.fetchMessage(chatUser: chatUser)
            
            chatMessageResponseDTO.forEach { chatMessage in
                let id = self.generateRoomId(
                    fromId: chatMessage.toDomain().fromId,
                    toId: chatMessage.toDomain().toId
                )
                self.saveMessage(
                    chatMessageResponse: chatMessage.toDomain(),
                    id: id
                )
            }
        } catch {
            throw error
        }
    }
    
    func checkChatUserUID(chatUserUID: String?, completion: @escaping (String) -> Void) {
        if chatUserUID != nil {
            dataSource.read(Conversation.self).forEach { conver in
                if conver.room?.name == chatUserUID {
                    completion(conver.room?.id ?? "")
                }
            }
        }
    }
    
    func startRealmConversationListener(chatUserUID: String?, completion: @escaping (String) -> Void) {
        let conversation = dataSource.read(Conversation.self)
        
        conversationListenerToken = conversation.observe { changes in
            switch changes {
            case .initial(_):
                return
            case .update(let conversation, _, let insertions, _):
                if insertions.count > 0 {
                    conversation.forEach { conver in
                        if conver.room?.name ?? "" == chatUserUID! {
                            self.conversationListenerToken?.invalidate()
                            completion(conver.room?.id ?? "")
                        }
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
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
    func startRealmChatMessageListener(chatRoomID: String, completion: @escaping (Result<ChatLog, Error>) -> Void) {
        let chatMessage = dataSource.read(Conversation.self).filter("room.id == %@", chatRoomID).first?.messages
        
        chetMessageListenerToken = chatMessage?.observe { changes in
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
    
    func startFirebaseChatMessageListener(chatUser: ChatUser, chatRoomID: String) {
        let recentChatMessageDate = fetchRecentChatMessageDate(chatRoomID: chatRoomID)
        
        firebaseSerivce.listenForChatMessage(chatUser: chatUser) { result in
            switch result {
            case .success(let documentChange):
                if documentChange.type == .added {
                    do {
                        let chatMessage = try documentChange.document.data(as: ChatMessageResponseDTO.self).toDomain()
                        
                        if chatMessage.timestamp > recentChatMessageDate {
                            let id = self.generateRoomId(
                                fromId: chatMessage.fromId,
                                toId: chatMessage.toId
                            )
                            self.saveMessage(
                                chatMessageResponse: chatMessage,
                                id: id
                            )
                        }
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
        let room = dataSource.read(Room.self)

        self.chatRoomListenerToken = room.observe { changes in
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
                    let filterRoom = self.dataSource.read(Room.self).filter(
                        filterQuery, chatRoomResponseDTO.toId, chatRoomResponseDTO.fromId, chatRoomResponseDTO.fromId, chatRoomResponseDTO.toId
                    )
                    
                    // 이미 저장되어 있다면 저장하지 않습니다.
                    if filterRoom.isEmpty {
                        self.saveRoom(from: chatRoomResponseDTO, id: nil)
                    }
                case .modified:
                    let id = self.generateRoomId(fromId: chatRoomResponseDTO.fromId, toId: chatRoomResponseDTO.toId)
                    self.saveRoom(from: chatRoomResponseDTO, id: id)
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
    
    private func fetchRecentChatMessageDate(chatRoomID: String) -> Date {
        let recentDate = dataSource.read(Conversation.self)
            .filter("room.id == %@", chatRoomID)
            .first?
            .messages.last?
            .timestamp

        return recentDate ?? Date()
    }
    
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
    private func generateRoomId(fromId: String, toId: String) -> String {
        let roomID = dataSource.read(Room.self)
            .filter("(name == %@) OR (name == %@)", fromId, toId)
            .first?
            .id
        
        return roomID ?? UUID().uuidString
    }
    
    private func saveMessage(chatMessageResponse: ChatMessageResponse, id: String) {
        let message = Message()

        message.fromId = chatMessageResponse.fromId
        message.toId = chatMessageResponse.toId
        message.text = chatMessageResponse.text
        message.imageUrl = chatMessageResponse.imageUrl
        message.videoUrl = chatMessageResponse.videoUrl
        message.imageWidth = chatMessageResponse.imageWidth
        message.imageHeight = chatMessageResponse.imageHeight
        message.fileTitle = chatMessageResponse.fileName
        message.fileSizes = chatMessageResponse.fileSize
        message.fileType = chatMessageResponse.fileType
        message.fileUrl = chatMessageResponse.fileUrl
        message.timestamp = chatMessageResponse.timestamp

        if let roomConversatcions = dataSource.read(Conversation.self).filter("room.id == %@", id).first {
            if roomConversatcions.messages.isEmpty {
                dataSource.update {
                    roomConversatcions.messages.append(message)
                }
            } else {
                if chatMessageResponse.timestamp > roomConversatcions.messages.last?.timestamp ?? Date() {
                    dataSource.update {
                        roomConversatcions.messages.append(message)
                    }
                }
            }
        }
    }
    
    private func saveRoom(from chatRoomResponse: ChatRoomResponse, id: String?) {
        let uuid = UUID().uuidString
        let friendUser = FriendUser()
        
        if chatRoomResponse.id == chatRoomResponse.fromId {
            friendUser.uid = chatRoomResponse.fromId
        } else {
            friendUser.uid = chatRoomResponse.toId
        }
        dataSource.create(FriendUser.self, value: friendUser)
        
        let newRoom = Room()
        
        // fromId와 toId를 설정 - 상대방 메세지만 보냈을 경우, id 중복 방지
        newRoom.id = id ?? uuid
        if chatRoomResponse.id == chatRoomResponse.fromId {
            newRoom.name = chatRoomResponse.fromId
            newRoom.fromId = chatRoomResponse.toId
            newRoom.toId = chatRoomResponse.fromId
        } else {
            newRoom.name = chatRoomResponse.toId
            newRoom.fromId = chatRoomResponse.toId
            newRoom.toId = chatRoomResponse.fromId
        }
        newRoom.profileImageURL = chatRoomResponse.profileImageURL
        newRoom.email = chatRoomResponse.email
        newRoom.participants.append(friendUser)
        newRoom.latestMessage = chatRoomResponse.text
        newRoom.timestamp = chatRoomResponse.timestamp
        
        dataSource.create(Room.self, value: newRoom)
        if let myCover = dataSource.read(Conversation.self).filter("room.id == %@", id ?? uuid).first {
            dataSource.update {
                myCover.timestamp = chatRoomResponse.timestamp
            }
            dataSource.create(Conversation.self, value: myCover)
        } else {
            let newConversation = Conversation()
            newConversation.room = newRoom
            newConversation.timestamp = newRoom.timestamp
            
            dataSource.create(Conversation.self, value: newConversation)
        }
    }
}
