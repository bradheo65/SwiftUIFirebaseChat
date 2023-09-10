//
//  DeleteRecentMessageUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/14.
//

import Foundation

protocol DeleteRecentMessageUseCaseProtocol {
    
    func execute(id: String, toId: String) async throws -> String

}

final class DeleteRecentMessageUseCase: DeleteRecentMessageUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    
    init(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
    }
    
    /**
     채팅 메시지 및 최근 메시지를 삭제하는 함수

     toId를 사용하여 채팅 메시지와 해당 최근 메시지를 삭제하는 역할을 합니다.
     삭제 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - toId: 삭제할 메시지의 대상 사용자 ID

     - Throws:
       - 기타 에러: 삭제 과정에서 발생한 에러를 전달

     - Returns: 삭제 결과 메시지
     */
    func execute(id: String, toId: String) async throws -> String {
        // 채팅 메시지를 삭제하고 결과를 관리하지 않습니다.
        let (_) = try await userRepo.deleteChatMessage(id: id, toId: toId)
        
        // 최근 메시지를 삭제하고 결과 메시지를 받아옵니다.
        let deleteRecentMessage = try await userRepo.deleteRecentMessage(id: id, toId: toId)
        
        return deleteRecentMessage
    }
    
}
