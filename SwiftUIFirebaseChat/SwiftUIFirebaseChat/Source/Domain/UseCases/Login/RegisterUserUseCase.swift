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
    
    /**
     사용자 등록을 처리하고 관련 정보를 저장하는 함수

     이 함수는 주어진 이메일, 비밀번호 및 이미지를 사용하여 사용자 등록 및 관련 정보를 저장하는 역할을 합니다.
     등록 및 정보 저장 완료 시 결과 메시지를 반환합니다.

     - Parameters:
       - email: 등록할 사용자의 이메일 주소
       - password: 사용자 비밀번호
       - image: 프로필 이미지 (옵션)

     - Throws:
       - `RegisterUserError.missingImage`: 이미지가 없을 경우 발생
       - 기타 에러: 각 단계에서 발생한 에러를 전달

     - Returns: 사용자 정보 저장 결과 메시지
     */
    func execute(email: String, password: String, image: UIImage?) async throws -> String {
        guard let image = image else {
            throw RegisterUserError.missingImage
        }
        
        // 사용자 등록 후 UID를 받아옵니다.
        let uid = try await userRepo.registerUser(
            email: email,
            password: password
        )
        
        // 이미지를 업로드하고 업로드된 이미지 URL을 받아옵니다.
        let uploadedImageUrl = try await fileUploadRepo.uploadImage(image: image)
        
        // 사용자 정보를 저장하고 저장 결과 메시지를 받아옵니다.
        let userInfoSaveResultMessage = try await userRepo.saveUserInfo(
            email: email,
            password: password,
            profileImageUrl: uploadedImageUrl,
            uid: uid
        )
        
        return userInfoSaveResultMessage
    }
    
}
