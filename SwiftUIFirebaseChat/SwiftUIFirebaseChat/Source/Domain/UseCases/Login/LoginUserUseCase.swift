//
//  LoginUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

protocol LoginUserUseCaseProtocol {
    
    func execute(email: String, password: String) async throws -> String
    
}

final class LoginUserUseCase: LoginUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    /**
     사용자 로그인을 처리하는 함수

     이 함수는 주어진 이메일과 비밀번호를 사용하여 사용자 로그인을 처리합니다.
     로그인 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - email: 로그인할 사용자의 이메일 주소
       - password: 사용자 비밀번호

     - Throws:
       - 기타 에러: 로그인 과정에서 발생한 에러를 전달

     - Returns: 로그인 결과 메시지
     */
    func execute(email: String, password: String) async throws -> String {
        return try await userRepo.loginUser(email: email, password: password)
    }
    
}
