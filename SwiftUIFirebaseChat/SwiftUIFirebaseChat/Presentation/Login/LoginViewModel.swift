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

    private let createAccountUseCase = CreateAccountUseCase(repo: CreateAccountRepository())
    
    func handleAction(isLoginMode: Bool, email: String, password: String, image: UIImage?) async {
        if isLoginMode {
            loginUser(email: email, password: password)
        } else {
            createAccountUseCase.excute(email: email, password: password, image: image) { result in
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

extension LoginViewModel {
    
    private func loginUser(email: String, password: String) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.loginStatusMessage = error.localizedDescription
                return
            }
            
            self.loginStatusMessage = "Success \(result?.user.uid ?? "")"
            print("Success \(result?.user.uid ?? "")")
            
            self.isLoginSuccess = true
        }
    }
    
}
