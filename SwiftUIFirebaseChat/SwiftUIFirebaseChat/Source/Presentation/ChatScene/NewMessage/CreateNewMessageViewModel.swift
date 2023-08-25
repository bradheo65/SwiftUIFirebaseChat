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
