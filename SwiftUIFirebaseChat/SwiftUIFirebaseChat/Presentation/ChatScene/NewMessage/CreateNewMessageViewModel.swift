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
    
    private let getAllUserUseCase: GetAllUserUseCaseProtocol
    
    init(getAllUserUseCase: GetAllUserUseCaseProtocol) {
        self.getAllUserUseCase = getAllUserUseCase
    }
    
    func fetchAllUser() {
        fetchFirebaseAllUser()
    }
    
}

extension CreateNewMessageViewModel {
    
    private func fetchFirebaseAllUser() {
        getAllUserUseCase.excute { result in
            switch result {
            case .success(let user):
                self.users.append(user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
