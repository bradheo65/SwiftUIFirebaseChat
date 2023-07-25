//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

import Firebase
struct RecentMessage: Identifiable {
    var id: String {
        documentId
    }
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageURL: String
    let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.profileImageURL = data[FirebaseConstants.profileImageURL] as? String ?? ""
        self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date:  Date())
    }
}
final class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?

    init() {
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    private func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        errorMessage = "Fetching current user \(uid)"

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            self.errorMessage = "123"
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            self.errorMessage = "Data \(data.description)"
    
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    @Published var recentMessages: [RecentMessage] = []
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { recentMessage in
                        return recentMessage.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                })
            }
    }
}

struct MainMessageView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = MainMessageViewModel()
    
    @State var shouldNavigatieToChatLogView = false
    
    var body: some View {
        NavigationView {
            VStack {
                CustomNavgationBar()
                    .environmentObject(viewModel)
                
                ScrollView {
                    ForEach(viewModel.recentMessages) { recentMessage in
                        VStack {
                            NavigationLink {
                                
                            } label: {
                                HStack(spacing: 16) {
                                    AsyncImage(
                                        url: URL(string: recentMessage.profileImageURL)) { image in image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipped()
                                        .cornerRadius(64)
                                        .overlay(RoundedRectangle(cornerRadius: 64)
                                            .stroke(Color(.label), lineWidth: 1))
                                        .shadow(radius: 5)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(recentMessage.email)
                                            .lineLimit(1)
                                            .font(.system(size: 16, weight: .bold))
                                        
                                        Text(recentMessage.text)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(.lightGray))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                    }
                                    Spacer()

                                    Text("Message row")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 50)
                }
                
                NavigationLink("", isActive: $shouldNavigatieToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(alignment: .bottom) {
                newMessageButton
            }
        }

        .navigationBarHidden(true)
        .onChange(of: viewModel.isUserCurrentlyLoggedOut) { newValue in
            dismiss()
        }
    }
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                print(user.email)
                shouldNavigatieToChatLogView.toggle()
                self.chatUser = user
            }
        }
    }
    
    @State var chatUser: ChatUser?
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
        
        MainMessageView()
            .preferredColorScheme(.dark)
    }
}

struct CustomNavgationBar: View {
    @EnvironmentObject var viewModel: MainMessageViewModel
    
    @State private var shouldShowLogoutOptions = false
    
    var body: some View {
        HStack {
            AsyncImage(
                url: URL(string: "\(viewModel.chatUser?.profileImageURL ?? "")")) { image in image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.chatUser?.email ?? "")")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            
            Button  {
                shouldShowLogoutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogoutOptions) {
            .init(
                title: Text("Setting"),
                message: Text("What do you want to do"),
                buttons: [
                    .destructive(
                        Text("Sign out"),
                        action: {
                            print("handle Sign out")
                            viewModel.handleSignOut()
                        }
                    ),
                    .default(Text("DEFAULT BUTTON")),
                    .cancel()
                ]
            )
        }
    }
}
