//
//  CreateNewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/24.
//

import SwiftUI

final class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var errorMessage = ""

    init() {
        fetchAllUser()
    }
    
    private func fetchAllUser() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
            if let error = error {
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                do {
                    let user = try snapshot.data(as: ChatUser.self)
                    self.users.append(user)
                } catch {
                    print(error)
                }
//                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
//                    self.users.append(.init(data: data))
//                }
            })
            
            self.errorMessage = "Fetched users successfully"
        }
    }
}
struct CreateNewMessageView: View {
    @Environment(\.dismiss) var dismiss
    
    let didSelectNewUser: (ChatUser) -> ()
    
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
                                AsyncImage(
                                    url: URL(string: "\(user.profileImageURL)")) { image in image.resizable()
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
        // CreateNewMessageView()
        MainMessageView()
    }
}
