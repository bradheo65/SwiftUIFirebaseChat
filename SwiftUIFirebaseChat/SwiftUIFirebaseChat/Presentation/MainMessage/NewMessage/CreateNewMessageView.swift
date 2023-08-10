//
//  CreateNewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/24.
//

import SwiftUI

struct CreateNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()

    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = CreateNewMessageViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        VStack {
                            HStack {
                                ProfileImageView(url: user.profileImageURL)
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
                }
                .padding(.horizontal)
            }
            .listStyle(.plain)
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
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
