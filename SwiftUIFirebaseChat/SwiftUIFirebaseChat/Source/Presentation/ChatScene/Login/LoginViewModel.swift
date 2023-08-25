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

    @MainActor
    func handleAction(isLoginMode: Bool, email: String, password: String, profileImage: UIImage?) {
        if isLoginMode {
            Task {
                do {
                    let loginResultMessage = try await loginUserUseCase.execute(email: email, password: password)
                    
                    self.loginStatusMessage = loginResultMessage
                    self.isLoginSuccess = true
                } catch {
                    print(error)
                }
            }
        } else {
            Task {
                do {
                    let registerUserResultMessage = try await registerUserUseCase.execute(email: email, password: password, image: profileImage)
                    
                    self.loginStatusMessage = registerUserResultMessage
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
}
