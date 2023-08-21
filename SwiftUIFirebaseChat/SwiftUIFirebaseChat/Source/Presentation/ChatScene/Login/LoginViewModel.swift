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

    private let registerUserUseCase: RegisterUserUseCaseProtocol
    private let loginUserUseCase: LoginUserUseCaseProtocol
    
    init(
        createAccountUseCase: RegisterUserUseCaseProtocol,
        loginUseCase: LoginUserUseCaseProtocol
    ) {
        self.registerUserUseCase = createAccountUseCase
        self.loginUserUseCase = loginUseCase
    }

    func handleAction(isLoginMode: Bool, email: String, password: String, profileImage: UIImage?) {
        if isLoginMode {
            loginUserUseCase.excute(email: email, password: password) { result in
                switch result {
                case .success(let message):
                    self.loginStatusMessage = message
                    self.isLoginSuccess = true
                case .failure(let error):
                    self.loginStatusMessage = error.localizedDescription
                }
            }
        } else {
            registerUserUseCase.excute(email: email, password: password, image: profileImage) { result in
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
