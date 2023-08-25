//
//  RegisterUserUseCase.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/09.
//

import SwiftUI

enum RegisterUserError: Error {
    case missingImage
}

protocol RegisterUserUseCaseProtocol {
    
    func execute(email: String, password: String, image: UIImage?) async throws -> String
    
}

final class RegisterUserUseCase: RegisterUserUseCaseProtocol {
    
    private let userRepo: UserRepositoryProtocol
    private let fileUploadRepo: FileUploadRepositoryProtocol

    init(userRepo: UserRepositoryProtocol, fileUploadRepo: FileUploadRepositoryProtocol) {
        self.userRepo = userRepo
        self.fileUploadRepo = fileUploadRepo
    }
    
    func execute(email: String, password: String, image: UIImage?) async throws -> String {
        guard let image = image else {
            throw RegisterUserError.missingImage
        }
        
        let (_) = try await userRepo.registerUser(email: email, password: password)
        let uploadedImageUrl = try await fileUploadRepo.uploadImage(image: image)
        let userInfoSaveResultMessage = try await userRepo.saveUserInfo(email: email, profileImageUrl: uploadedImageUrl)
        
        return userInfoSaveResultMessage
    }
    
}
