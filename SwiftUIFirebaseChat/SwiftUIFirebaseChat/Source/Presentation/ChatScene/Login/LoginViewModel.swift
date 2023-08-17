//
//  LoginViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/08.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    
    @Published var loginStatusMessage = ""
    
    @Published var isLoginSuccess = false

    private let createAccountUseCase: CreateAccountUseCaseProtocol
    private let loginUseCase: LoginUseCaseProtocol
    
    init(
        createAccountUseCase: CreateAccountUseCaseProtocol,
        loginUseCase: LoginUseCaseProtocol
    ) {
        self.createAccountUseCase = createAccountUseCase
        self.loginUseCase = loginUseCase
    }

    func handleAction(isLoginMode: Bool, email: String, password: String, profileImage: UIImage?) {
        if isLoginMode {
            loginUseCase.excute(email: email, password: password) { result in
                switch result {
                case .success(let message):
                    self.loginStatusMessage = message
                    self.isLoginSuccess = true
                case .failure(let error):
                    self.loginStatusMessage = error.localizedDescription
                }
            }
        } else {
            createAccountUseCase.excute(email: email, password: password, image: profileImage) { result in
                switch result {
                case .success(let message):
                    self.loginStatusMessage = message
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}
