//
//  LogoutUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol LogoutUseCaseProtocol {
    
    func excute() throws -> String
    
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    /**
     사용자 로그아웃을 처리하는 함수

     이 함수는 사용자 로그아웃을 처리합니다.
     로그아웃 완료 시 결과 메시지를 반환합니다.

     - Throws:
       - 기타 에러: 로그아웃 과정에서 발생한 에러를 전달

     - Returns: 로그아웃 결과 메시지
     */
    func excute() throws -> String {
        return try userRepo.logoutUser()
    }
    
}
