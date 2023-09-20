//
//  LoginView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/04.
//

import SwiftUI

enum LoginMode: CaseIterable {
    case login
    case signup
    
    var title: String {
        switch self {
        case .login:
            return "Log in"
        case .signup:
            return "Sign up"
        }
    }
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel(
        createAccountUseCase: Reslover.shared.resolve(RegisterUserUseCaseProtocol.self),
        loginUseCase: Reslover.shared.resolve(LoginUserUseCaseProtocol.self)
    )
    @State private var loginMode: LoginMode = .login
    
    @State private var profileImage: UIImage?
    
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $loginMode, label: Text("Picker here")) {
                        ForEach(LoginMode.allCases, id: \.self) { mode in
                            Text(mode.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if loginMode == .signup {
                        ProfileImageSelectButtonView(profileImage: $profileImage)
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        viewModel.handleAction(
                            loginMode: loginMode,
                            email: email,
                            password: password,
                            profileImage: profileImage
                        )
                    } label: {
                        HStack {
                            Spacer()
                            Text(loginMode.title)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(.purple)
                        .cornerRadius(6)
                    }
                }
                .padding()
            }
            .navigationTitle(loginMode.title)
            .background(
                Color(uiColor: .secondarySystemBackground)
            )
            .showLoading(isLoading: viewModel.isLoading)
        }
        .alert("Success", isPresented: $viewModel.isAlert, actions: {
            Button("Ok") { }
        })
        .showErrorMessage(
            showAlert: $viewModel.isErrorAlert,
            message: viewModel.loginStatusMessage
        )
        .fullScreenCover(isPresented: $viewModel.isLoginSuccess) {
            MainMessageView()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

private struct ProfileImageSelectButtonView: View {
    @State private var shouldShowImagePicker = false

    @Binding private var profileImage: UIImage?
    
    fileprivate init(profileImage: Binding<UIImage?>) {
        self._profileImage = profileImage
    }
    
    fileprivate var body: some View {
        Button {
            shouldShowImagePicker.toggle()
        } label: {
            VStack {
                if let image = self.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .cornerRadius(64)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 64))
                        .padding()
                        .foregroundColor(.black)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 64)
                    .stroke(.black, lineWidth: 3)
            )
        }
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $profileImage, videoUrl: .constant(nil))
        }
    }
}
