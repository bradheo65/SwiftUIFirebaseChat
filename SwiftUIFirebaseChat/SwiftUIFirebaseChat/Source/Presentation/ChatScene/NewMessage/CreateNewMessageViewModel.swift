//
//  CreateNewMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation

final class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    
    private let fetchAllUserUseCase: FetchAllUserUseCaseProtocol
    
    init(fetchAllUserUseCase: FetchAllUserUseCaseProtocol) {
        self.fetchAllUserUseCase = fetchAllUserUseCase
    }
    
    /**
    모든 사용자 정보를 가져오는 함수
     
     가져온 정보는 'users' 프로퍼티에 저장
     
     - Throws: 'fetchAllUserUseCase.excute()' 메서드가 실패한 경우 에러를 출력
     */
    func fetchAllUser() async {
        do {
            let users = try await fetchAllUserUseCase.excute()
            
            DispatchQueue.main.async {
                self.users = users
            }
        } catch {
            print(error)
        }
    }
    
}
