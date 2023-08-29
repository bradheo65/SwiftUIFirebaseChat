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
    
    func startChatMessageListener(chatUser: ChatUser, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        firebaseSerivce.listenForChatMessage(chatUser: chatUser) { result in
            switch result {
            case .success(let documentChange):
                if documentChange.type == .added {
                    do {
                        let chatMessage = try documentChange.document.data(as: ChatMessage.self)
                        
                        let chatLog = ChatLog()
                        
                        let id = self.realm.objects(ChatList.self)
                            .filter(
                                "(toId == %@ AND fromId == %@) OR (toId == %@ AND fromId == %@)",
                                chatMessage.toId, chatMessage.fromId, chatMessage.fromId, chatMessage.toId
                            )
                            .first?.id ?? chatMessage.toId
                        
                        chatLog.id = id
                        
                        chatLog.fromId = chatMessage.fromId
                        chatLog.toId = chatMessage.toId
                        chatLog.text = chatMessage.text
                        chatLog.imageUrl = chatMessage.imageUrl
                        chatLog.videoUrl = chatMessage.videoUrl
                        chatLog.fileUrl = chatMessage.fileUrl
                        chatLog.imageWidth = RealmOptional(chatMessage.imageWidth)
                        chatLog.imageHeight = RealmOptional(chatMessage.imageHeight)
                        chatLog.timestamp = chatMessage.timestamp
                        chatLog.fileTitle = chatMessage.fileTitle
                        chatLog.fileSizes = chatMessage.fileSizes
                        
                        if self.realm.objects(ChatLog.self)
                            .filter("id == %@", id)
                            .isEmpty {
                            self.realm.writeAsync {
                                self.realm.add(chatLog)
                            }
                        } else if let date = self.realm.objects(ChatLog.self)
                            .filter("id == %@", id)
                            .last?.timestamp {
                            
                            if date < chatMessage.timestamp {
                                self.realm.writeAsync {
                                    self.realm.add(chatLog)
                                }
                            }
                        }
                        
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
    
    func startRecentMessageListener(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var chatRoomList: [ChatRoom] = []
        
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                switch documentChange.type {
                case .added, .modified:
                    let docId = documentChange.document.documentID
                    
                    if let index = chatRoomList.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        chatRoomList.remove(at: index)
                    }
                    if let chatRoom = try? documentChange.document.data(as: ChatRoom.self) {
                        chatRoomList.insert(chatRoom, at: 0)
                        
                        let chatList = ChatList()

                        chatList.id = chatRoom.id ?? ""
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
