//
//  CreateNewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/24.
//

import SwiftUI

struct CreateNewMessageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedChatUser: ChatUser?
    @Binding var isDismiss: Bool

    @StateObject private var viewModel = CreateNewMessageViewModel(
        fetchAllUserUseCase: Reslover.shared.resolve(FetchAllUserUseCaseProtocol.self)
    )

    var body: some View {
        NavigationView {
            ChatUserListView(
                viewModel: viewModel,
                selectedChatUser: $selectedChatUser,
                isDismiss: $isDismiss
            )
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchAllUser()
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}

private struct ChatUserListView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel: CreateNewMessageViewModel
    
    @Binding private var selectedChatUser: ChatUser?
    @Binding private var isDismiss: Bool

    fileprivate init(
        viewModel: CreateNewMessageViewModel,
        selectedChatUser: Binding<ChatUser?>,
        isDismiss: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._selectedChatUser = selectedChatUser
        self._isDismiss = isDismiss
    }
    
    fileprivate var body: some View {
        List {
            ForEach(viewModel.users, id: \.self) { user in
                Button {
                    selectedChatUser = user
                    dismiss()
                    isDismiss.toggle()
                } label: {
                    ChatUserListCell(user: user)
                }
            }
            .padding(.horizontal)
        }
        .listStyle(.plain)
    }
}

private struct ChatUserListCell: View {
    private var user: ChatUser
    
    fileprivate init(user: ChatUser) {
        self.user = user
    }
    
    fileprivate var body: some View {
        HStack {
            ProfileImageView(url: user.profileImageURL)
                .aspectRatio(0.3, contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50)
                    .stroke(Color(.label), lineWidth: 1))
            
            Text(user.username)
            
            Spacer()
        }
    }
}
