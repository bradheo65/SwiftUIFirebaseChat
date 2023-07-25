//
//  ChatLogVIew.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import SwiftUI

import Firebase

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let profileImageURL = "profileImageURL"
    static let email = "email"
}

struct ChatMessage: Identifiable {
    var id: String {
        documentID
    }
    
    let documentID: String
    let fromId, toId, text: String
    
    init(documentID: String, data: [String: Any]) {
        self.documentID = documentID
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

final class ChatLogViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    
    @Published var chatMessages: [ChatMessage] = []
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    func handleSend(text: String, compltion: @escaping () -> Void) {
        print(text)
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [
            FirebaseConstants.fromId : fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: text,
            FirebaseConstants.timestamp: Timestamp()
        ] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage(text: text)
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            compltion()
            print("Successfully saved current user sending message")
        }
    }
    
    private func persistRecentMessage(text: String) {
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        guard let toId = self.chatUser?.uid else {
            return
        }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageURL: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentID: change.document.documentID, data: data))
                    }
                    guard let text = change.document.data()["text"] as? String else { return }
                    
                    self.persistRecentMessage(text: text)
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    @Published var count = 0
}

struct ChatLogView: View {
    let chatUser: ChatUser?

    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self._viewModel = .init(
            wrappedValue: .init(chatUser: chatUser)
        )
    }
    
    @StateObject var viewModel: ChatLogViewModel

    @State var chatText = ""
    
    var body: some View {
        ZStack {
            messageView
            Text(viewModel.errorMessage)
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messageView: some View {
        ScrollView {
            ScrollViewReader { scollViewProxy in
                VStack {
                    ForEach(viewModel.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .id("Empty")
                }
                .onReceive(viewModel.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scollViewProxy.scrollTo("Empty", anchor: .bottom)
                    }
                }
            }
          
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground))
                .ignoresSafeArea()
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle")
            
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button {
                viewModel.handleSend(text: self.chatText) {
                    self.chatText = ""
                }
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ChatLogVIew_Previews: PreviewProvider {
    static var previews: some View {
//            ChatLogView(chatUser: .init(data: [
//                "uid": "Gc9KTdH5ZCUln1QLT9pbbj4Y5Qv2",
//                "email": "Water@gmail.com"
//            ]))
            MainMessageView()
    }
}
private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
   
}
