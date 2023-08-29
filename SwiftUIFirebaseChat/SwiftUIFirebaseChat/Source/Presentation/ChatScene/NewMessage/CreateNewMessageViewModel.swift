//
//  CreateNewMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var errorMessage = ""
    
    private let fetchAllUserUseCase: FetchAllUserUseCaseProtocol
    
    init(fetchAllUserUseCase: FetchAllUserUseCaseProtocol) {
        self.fetchAllUserUseCase = fetchAllUserUseCase
    }
    
    @MainActor
    func fetchAllUser() {
        fetchFirebaseAllUser()
    }
    
}

extension CreateNewMessageViewModel {

    /**
    모든 사용자 정보를 가져오는 함수
     
     가져온 정보는 'users' 프로퍼티에 저장
     
     - Throws: 'fetchAllUserUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     
     */
    @MainActor
    private func fetchFirebaseAllUser() {
        Task {
            do {
                let users = try await fetchAllUserUseCase.excute()
                
                self.users = users
            } catch {
                print(error)
            }
        }
    }
    
}
