//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

final class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?

    func fetchCurrentUser() {
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
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessageView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = MainMessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("User: \(viewModel.chatUser?.uid ?? "")")

                CustomNavgationBar()
                    .environmentObject(viewModel)
                
                MessageView()
            }
        }
        .overlay(alignment: .bottom) {
            newMessageButton
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isUserCurrentlyLoggedOut) { newValue in
            dismiss()
        }
        .onAppear {
            viewModel.fetchCurrentUser()
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
            CreateNewMessageView()
        }
    }
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

struct MessageView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                        
                        VStack(alignment: .leading) {
                            Text("UserName")
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        
                        Text("Message row\(num)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
}

//struct newMessageButton: View {
//    var body: some View {
//        Button {
//
//        } label: {
//            HStack {
//                Spacer()
//                Text("+ New message")
//                    .font(.system(size: 16, weight: .bold))
//                Spacer()
//            }
//            .foregroundColor(.white)
//            .padding(.vertical)
//            .background(.blue)
//            .cornerRadius(32)
//            .padding(.horizontal)
//            .shadow(radius: 15)
//        }
//    }
//}
