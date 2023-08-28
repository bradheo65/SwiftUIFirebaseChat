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
                                chatMessage.toId, chatMessage.fromId, chatMessage.fromId, chatMessage.toId)
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
                        chatLog.fileTitle = chatMessage.fileSizes
                        
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
    
    func startRecentMessageListener(completion: @escaping (Result<[RecentMessage], Error>) -> Void) {
        var recentMessages: [RecentMessage] = []
        
        firebaseSerivce.listenForRecentMessage { result in
            switch result {
            case .success(let documentChange):
                switch documentChange.type {
                case .added, .modified:
                    let docId = documentChange.document.documentID
                    
                    if let index = recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.id == docId
                    }) {
                        recentMessages.remove(at: index)
                    }
                    if let rm = try? documentChange.document.data(as: RecentMessage.self) {
                        recentMessages.insert(rm, at: 0)
                        
                        let recentChat = ChatList()

                        recentChat.id = rm.id ?? ""
                        recentChat.text = rm.text
                        recentChat.username = rm.username
                        recentChat.email = rm.email
                        recentChat.fromId = rm.fromId
                        recentChat.toId = rm.toId
                        recentChat.profileImageURL = rm.profileImageURL
                        recentChat.timestamp = rm.timestamp
                        
                        self.realm.writeAsync {
                            self.realm.create(ChatList.self, value: recentChat, update: .modified)
                        }
                        
                        completion(.success(recentMessages))
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
