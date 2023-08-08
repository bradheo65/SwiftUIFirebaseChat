//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

struct MainMessageView: View {
    @Environment(\.dismiss) var dismiss

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
                    ForEach(viewModel.recentMessages, id: \.email) { recentMessage in
                        Button {
                            checkUser(recentMessage: recentMessage)
                        } label: {
                            HStack(spacing: 16) {
                                ProfileImageView(url: recentMessage.profileImageURL)
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color(.label), lineWidth: 1))
                                    .shadow(radius: 5)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(recentMessage.username)
                                        .lineLimit(1)
                                        .foregroundColor(.black)
                                        .font(.system(size: 16, weight: .bold))
                                    
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                }
                                
                                Spacer()
                                
                                Text(recentMessage.timeAgo)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        deleteAction(indexSet: indexSet)
                    }
                }
                .listStyle(.plain)

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
                            print("handle Sign out")
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
    
}

extension MainMessageView {
    
    private func checkUser(recentMessage: RecentMessage) {
        viewModel.users.forEach({ user in
            if recentMessage.email == user.email {
                self.chatUser = user
            }
         })
        shouldNavigatieToChatLogView.toggle()
    }
    
    private func deleteAction(indexSet: IndexSet) {
        viewModel.deleteChat(toId: viewModel.recentMessages[indexSet.first!].toId) {
            viewModel.recentMessages.remove(atOffsets: indexSet)
        }
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
