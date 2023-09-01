//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

struct MainMessageView: View {
    
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = MainMessageViewModel(
        logoutUseCase: Reslover.shared.resolve(LogoutUseCaseProtocol.self),
        deleteRecentMessageUseCase: Reslover.shared.resolve(DeleteRecentMessageUseCaseProtocol.self),
        fetchAllUserUseCase: Reslover.shared.resolve(FetchAllUserUseCaseProtocol.self),
        fetchCurrentUserUseCase: Reslover.shared.resolve(FetchCurrentUserUseCaseProtocol.self),
        startRecentMessageListenerUseCase: Reslover.shared.resolve(StartRecentMessageListenerUseCaseProtocol.self),
        stopRecentMessageListenerUseCase: Reslover.shared.resolve(StopRecentMessageListenerUseCaseProtocol.self)
    )
    
    @State private var shouldNavigatieToChatLogView = false
    @State private var shouldShowNewMessageScreen = false
    @State private var shouldShowLogoutOptions = false

    @State private var chatUser: ChatUser?

    var body: some View {
        NavigationView {
            VStack {
                currentUserTitleView
                 
                List {
                    ForEach(viewModel.chatRoomList, id: \.id) { recentMessage in
                        NavigationLink {
                            ChatLogView(
                                chatUser: ChatUser(
                                    uid: recentMessage.toId ?? "",
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
            viewModel.fetchAllUser()
            viewModel.fetchCurrentUser()
            viewModel.addRecentMessageListener()
        }
        .onDisappear {
            viewModel.removeRecentMessageListener()
        }
    }
    
}

extension MainMessageView {
    
    private var currentUserTitleView: some View {
        HStack {
            ProfileImageView(url: viewModel.currentUser?.profileImageURL ?? "")
                .aspectRatio(0.3, contentMode: .fill)
                .frame(width: 50, height: 50, alignment: .center)
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.currentUser?.username ?? "")")
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
                            viewModel.handleLogout()
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
    
    func messageListCell(message: ChatList) -> some View {
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
        viewModel.deleteRecentChatMessage(indexSet: indexSet) 
    }
    
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
