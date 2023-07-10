//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/10.
//

import SwiftUI

struct MainMessageView: View {
    var body: some View {
        NavigationView {
            VStack {
                CustomNavgationBar()
                
                MessageView()
            }
        }
        .overlay(alignment: .bottom) {
            newMessageButton()
        }
        .navigationBarHidden(true)
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
    @State private var shouldShowLogoutOptions = false
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("user name")
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
                            print("handle Sogn out")
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

struct newMessageButton: View {
    var body: some View {
        Button {
            
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
    }
}
