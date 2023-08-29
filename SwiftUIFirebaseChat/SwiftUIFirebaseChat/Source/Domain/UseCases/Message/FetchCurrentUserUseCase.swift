//
//  FetchCurrentUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol FetchCurrentUserUseCaseProtocol {
    
    func excute() async throws -> ChatUser?

}

final class FetchCurrentUserUseCase: FetchCurrentUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol

    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    /**
     현재 채팅 사용자 정보를 가져오는 함수

     이 함수는 현재 채팅 사용자의 정보를 가져오는 역할을 합니다.
     가져온 사용자 정보를 ChatUser타입으로 반환합니다.

     - Throws:
       - 기타 에러: 사용자 정보 가져오기 과정에서 발생한 에러를 전달

     - Returns: 현재 채팅 사용자의 정보
     */
    func excute() async throws -> ChatUser? {
        return try await userRepo.fetchCurrentUser()
    }
    
}
