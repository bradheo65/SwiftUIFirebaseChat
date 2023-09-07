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

    /**
     로그인 모드에 따른 로그인, 회원가입 선택 실행 함수
     
     - Parameters:
        - loginMode: 로그인 모드(true: 로그인, false: 회원가입)
        - email: View에 입력된 이메일 주소
        - password: View에 입력된 비밀번호
        - profileImage: imagePicker로 선택한 image
     */
    @MainActor
    func handleAction(loginMode: LoginMode, email: String, password: String, profileImage: UIImage?) {
        if loginMode == .login {
            login(email: email, password: password)
        } else {
            register(email: email, password: password, image: profileImage)
        }
    }
}

extension LoginViewModel {
    /**
     로그인 실행 함수
     
     'loginStatusMessage'에 로그인 상태 메시지 업데이트, 'isLoginSuccess' 상태 업데이트
     
     - Parameters:
        - email: 등록한 이메일 주소
        - password: 이메일 주소에 맞는 비밀번호
     
     - Throws: 'loginStatusMessage'에 로그인 상태 메시지 업데이트
     */
    @MainActor
    private func login(email: String, password: String) {
        Task {
            do {
                let loginResultMessage = try await loginUserUseCase.execute(
                    email: email,
                    password: password
                )
                self.loginStatusMessage = loginResultMessage
                self.isLoginSuccess = true
            } catch {
                self.loginStatusMessage = error.localizedDescription
            }
        }
    }
    
    /**
     회원가입 실행 함수
     
     'loginStatusMessage'에 회원가입 상태 메시지 업데이트
     
     - Parameters:
        - email: 회원가입 이메일 주소
        - password: 회원가입 이메일 주소에 대한 비밀번호
        - image: 프로필 이미지로 등록할 이미지
     
     - Throws: 'loginStatusMessage'에 회원가입 상태 메시지 업데이트
     */
    @MainActor
    private func register(email: String, password: String, image: UIImage?) {
        Task {
            do {
                let registerUserResultMessage = try await registerUserUseCase.execute(
                    email: email,
                    password: password,
                    image: image
                )
                self.loginStatusMessage = registerUserResultMessage
            } catch {
                self.loginStatusMessage = error.localizedDescription
            }
        }
    }
}
