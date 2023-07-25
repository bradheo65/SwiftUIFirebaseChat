//
//  ChatLogVIew.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/25.
//

import SwiftUI

import Firebase

final class ChatLogViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
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
        
        let messageData = ["fromId" : fromId, "toId": toId, "text": text, "timestamp": Timestamp()] as [String : Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
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
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Fake Messages for now")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            HStack { Spacer() }
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
        NavigationView {
            ChatLogView(chatUser: .init(data: [
                "uid": "Gc9KTdH5ZCUln1QLT9pbbj4Y5Qv2",
                "email": "Water@gmail.com"
            ]))
        }
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
