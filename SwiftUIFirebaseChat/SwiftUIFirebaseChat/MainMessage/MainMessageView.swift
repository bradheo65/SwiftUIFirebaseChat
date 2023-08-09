//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

struct MainMessageView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = MainMessageViewModel()
    
    @State private var chatUser: ChatUser?

    @State private var shouldNavigatieToChatLogView = false
    @State private var shouldShowNewMessageScreen = false
    @State private var shouldShowLogoutOptions = false

    var body: some View {
        NavigationView {
            VStack {
                currentUserTitleView
                
                List {
                    ForEach(viewModel.recentMessages, id: \.id) { recentMessage in
                        NavigationLink {
                            ChatLogView(
                                chatUser: ChatUser(
                                    uid: recentMessage.id ?? "",
                                    email: recentMessage.email,
                                    profileImageURL: recentMessage.profileImageURL
                                )
                            )
                        } label: {
                            messageListCell(message: recentMessage)
                        }
                    }
                    .onDelete { indexSet in
                        deleteAction(indexSet: indexSet)
                    }
                }
                .listStyle(.plain)
                
                NavigationLink("", isActive: $shouldNavigatieToChatLogView) {
                    ChatLogView(chatUser: chatUser)
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
        .onAppear {
            viewModel.fetch()
            viewModel.activeFirebaseListener()
        }
        .onDisappear {
            viewModel.removeFirebaseListener()
        }
    }
    
}

extension MainMessageView {
    
    private var currentUserTitleView: some View {
        HStack {
            ProfileImageView(url: viewModel.chatUser?.profileImageURL ?? "")
                .frame(width: 50, height: 50)
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.chatUser?.username ?? "")")
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
                message: nil,
                buttons: [
                    .destructive(
                        Text("Sign out"),
                        action: {
                            viewModel.handleSignOut()
                        }
                    ),
                    .cancel()
                ]
            )
        }
    }
    
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
            .background(.purple)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                shouldNavigatieToChatLogView.toggle()
                self.chatUser = user
            }
        }
    }
    
    func messageListCell(message: RecentMessage) -> some View {
        var body: some View {
            HStack(spacing: 16) {
                ProfileImageView(url: message.profileImageURL)
                    .frame(width: 64, height: 64)
                    .cornerRadius(64)
                    .overlay(RoundedRectangle(cornerRadius: 64)
                        .stroke(Color(.label), lineWidth: 1))
                    .shadow(radius: 5)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(message.username)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(message.text)
                        .font(.system(size: 14))
                        .foregroundColor(Color(.lightGray))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
                
                Text(message.timeAgo)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        return body
    }
    
}

extension MainMessageView {
    
    private func deleteAction(indexSet: IndexSet) {
        viewModel.deleteChat(indexSet: indexSet) 
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
