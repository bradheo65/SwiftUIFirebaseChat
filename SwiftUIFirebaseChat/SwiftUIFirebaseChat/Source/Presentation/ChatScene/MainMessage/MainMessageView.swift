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

    @State private var chatUser: ChatUser?

    var body: some View {
        NavigationStack {
            VStack {
                UserProfileHeaderView(viewModel: viewModel)
                
                ChatRoomListView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $shouldNavigatieToChatLogView) {
                ChatLogView(chatUser: chatUser)
            }
            .overlay(alignment: .bottom) {
                NewMessageButtonView(
                    chatUser: $chatUser,
                    isShowingChatMessageView: $shouldNavigatieToChatLogView
                )
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

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}

private struct UserProfileHeaderView: View {
    @ObservedObject private var viewModel: MainMessageViewModel
    
    @State private var isShowingSettingView = false

    fileprivate init(viewModel: MainMessageViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate var body: some View {
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
                isShowingSettingView.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $isShowingSettingView) {
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
}

private struct ChatRoomListView: View {
    @ObservedObject private var viewModel: MainMessageViewModel
    
    fileprivate init(viewModel: MainMessageViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate var body: some View {
        List {
            ForEach(viewModel.chatRoomList.sorted(), id: \.id) { recentMessage in
                NavigationLink {
                    ChatLogView(
                        chatUser: ChatUser(
                            uid: recentMessage.toId ,
                            email: recentMessage.email,
                            profileImageURL: recentMessage.profileImageURL
                        )
                    )
                } label: {
                    ChatRoomListCell(message: recentMessage)
                }
            }
            .onDelete { indexSet in
                deleteAction(indexSet: indexSet)
            }
        }
        .listStyle(.plain)
    }
    
    private func deleteAction(indexSet: IndexSet) {
        viewModel.deleteRecentChatMessage(indexSet: indexSet)
    }
    
}

private struct ChatRoomListCell: View {
    private var message: ChatList
    
    fileprivate init(message: ChatList) {
        self.message = message
    }
    
    fileprivate var body: some View {
        HStack(spacing: 16) {
            ProfileImageView(url: message.profileImageURL)
                .aspectRatio(0.3, contentMode: .fill)
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
}

private struct NewMessageButtonView: View {
    @Binding private var chatUser: ChatUser?
    @Binding private var isShowingChatMessageView: Bool

    @State private var isShowingCreateNewMessageView = false
    
    fileprivate init(
        chatUser: Binding<ChatUser?>,
        isShowingChatMessageView: Binding<Bool>
    ) {
        self._chatUser = chatUser
        self._isShowingChatMessageView = isShowingChatMessageView
    }

    fileprivate var body: some View {
        Button {
            isShowingCreateNewMessageView.toggle()
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
        .fullScreenCover(isPresented: $isShowingCreateNewMessageView) {
            CreateNewMessageView(
                selectedChatUser: $chatUser,
                isDismiss: $isShowingChatMessageView
            )
        }
    }
}
