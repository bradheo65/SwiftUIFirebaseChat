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
    private let realm = try! Realm()

    init(firebaseSerivce: FirebaseChatListenerProtocol) {
        self.firebaseSerivce = firebaseSerivce
    }
    
    /**
     채팅 메시지를 감지하여 처리하는 함수

     이 함수는 주어진 대화 상대의 ChatUser 정보를 기반으로 Firebase에서 채팅 메시지를 감지하고, 새로운 메시지가 추가되었을 경우 해당 메시지를 처리합니다.

     - Parameters:
       - chatUser: 대화 상대의 ChatUser 정보
       - completion: 메시지 처리 결과를 담은 Result<ChatMessage, Error>를 반환하는 클로저

     - Note: Firebase에서 채팅 메시지를 감지하여 새로운 메시지가 추가되었을 경우, 해당 메시지를 처리하고 ChatLog 객체를 Realm에 저장합니다.
     */
    func startChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        firebaseSerivce.listenForChatMessage(chatUser: chatUser) { result in
            switch result {
            case .success(let documentChange):
                if documentChange.type == .added {
                    do {
                        let chatMessage = try documentChange.document.data(as: ChatMessage.self)
                                       
                        let id = self.generateChatLogId(fromId: chatMessage.fromId, toId: chatMessage.toId)
                        let chatLog = self.createChatLog(from: chatMessage, with: id)
                        
                        self.saveChatLog(chatLog, with: id)
                        
                        completion(.success(chatMessage))
                    } catch {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
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
       - completion: 최근 메시지 처리 결과를 담은 Result<[ChatRoom], Error>를 반환하는 클로저
     
     - Note: Firebase에서 최근 메시지를 감지하여 메시지의 추가 또는 수정 사항이 발생한 경우, 해당 메시지를 처리하고 ChatRoom 객체를 생성하여 ChatListLog를 만듭니다.
     */
    func startRecentMessageListener(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var chatRoomList: [ChatRoom] = []
        
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                switch documentChange.type {
                case .added, .modified:
                    let docId = documentChange.document.documentID
                    
                    // 이미 존재하는 메시지인 경우 리스트에서 제거
                    if let index = chatRoomList.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        chatRoomList.remove(at: index)
                    }
                    // 새로운 메시지를 ChatRoom 객체로 변환하여 리스트의 맨 앞에 추가
                    if let chatRoom = try? documentChange.document.data(as: ChatRoom.self) {
                        chatRoomList.insert(chatRoom, at: 0)
                        
                        if documentChange.type == .added {
                            let filterQuery = "toId == %@ AND fromId == %@"
                        
                            // 이미 저장되어 있다면 저장하지 않습니다.
                            if self.realm.objects(ChatList.self)
                                .filter(
                                    filterQuery,
                                    chatRoom.toId, chatRoom.fromId
                                ).isEmpty {
                                self.createChatListLog(from: chatRoom, id: nil)
                            }
                        } else {
                            let id = self.generateChatLogId(fromId: chatRoom.fromId, toId: chatRoom.toId)
                            self.createChatListLog(from: chatRoom, id: id)
                        }
                        completion(.success(chatRoomList))
                    }
                case .removed:
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func stopRecentMessageListener() {
        firebaseSerivce.stopListenForRecentMessage()
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
        
        let id = self.realm.objects(ChatList.self)
            .filter(
                filterQuery,
                toId, fromId, fromId, toId
            )
            .first?.id

        return id ?? ""
    }
    
    private func createChatLog(from chatMessage: ChatMessage, with id: String) -> ChatLog {
        let chatLog = ChatLog()
        
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
        chatLog.fileUrl = chatMessage.fileUrl
        chatLog.timestamp = chatMessage.timestamp

        return chatLog
    }
    
    private func saveChatLog(_ chatLog: ChatLog, with id: String) {
        let filterQuery = "id == %@"
        
        if realm.objects(ChatLog.self)
            .filter(filterQuery, id)
            .isEmpty {
            // 중복된 ChatLog가 없을 경우 ChatLog를 Realm에 추가합니다.
            self.realm.writeAsync {
                self.realm.add(chatLog)
            }
        } else if let date = realm.objects(ChatLog.self)
            .filter(filterQuery, id)
            .last?.timestamp {
            // 이미 존재하는 ChatLog 중 가장 마지막 메시지의 타임스탬프와 비교하여 최신 메시지인 경우 추가합니다.
            if date < chatLog.timestamp {
                self.realm.writeAsync {
                    self.realm.add(chatLog)
                }
            }
        }
    }
    
    private func createChatListLog(from chatRoom: ChatRoom, id: String?) {
        let chatList = ChatList()

        chatList.id = id ?? UUID().uuidString
        chatList.text = chatRoom.text
        chatList.username = chatRoom.username
        chatList.email = chatRoom.email
        chatList.fromId = chatRoom.fromId
        chatList.toId = chatRoom.toId
        chatList.profileImageURL = chatRoom.profileImageURL
        chatList.timestamp = chatRoom.timestamp
        
        self.realm.writeAsync {
            self.realm.create(ChatList.self, value: chatList, update: .modified)
        }
    }
    
}
