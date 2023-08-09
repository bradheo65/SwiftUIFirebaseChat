//
//  LoginViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/08.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    @Published var loginStatusMessage = ""
    
    @Published var isLoginSuccess = false

    func handleAction(isLoginMode: Bool, email: String, password: String, image: UIImage?) {
        if isLoginMode {
            loginUser(email: email, password: password)
        } else {
            createNewAccount(email: email, password: password, image: image)
        }
    }
}

extension LoginViewModel {
    private func createNewAccount(email: String, password: String, image: UIImage?) {
        guard let image = image else {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.loginStatusMessage = error.localizedDescription
                return
            }
            
            self.loginStatusMessage = "Success \(result?.user.uid ?? "")"
            print("Success \(result?.user.uid ?? "")")
            
            self.persiststImageToStorage(email: email, image: image)
        }
    }
    
    private func persiststImageToStorage(email: String, image: UIImage) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference()
            .child(FirebaseConstants.Storage.userProfileImages)
            .child(uid)
        
        FirebaseManager.shared.uploadImage(image: image, storageReference: ref) { result in
            switch result {
            case .success(let url):
                self.storeUserInformation(email: email, imageProfileURL: url)

            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func storeUserInformation(email: String, imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        
        let userData = [
            FirebaseConstants.email: email,
            FirebaseConstants.uid: uid,
            FirebaseConstants.profileImageURL: imageProfileURL.absoluteString
        ]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                print("success")
            }
    }
    
    private func loginUser(email: String, password: String) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.loginStatusMessage = error.localizedDescription
                return
            }
            
            self.loginStatusMessage = "Success \(result?.user.uid ?? "")"
            print("Success \(result?.user.uid ?? "")")
            
            self.isLoginSuccess = true
        }
    }
}
