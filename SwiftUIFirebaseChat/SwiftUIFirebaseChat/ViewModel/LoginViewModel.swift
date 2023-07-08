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
    
    private func persiststImageToStorage(email: String, image: UIImage?) {
        _ = UUID().uuidString
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        ref.putData(imageData) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image \(err)"
                return
            }
            
            ref.downloadURL { url, error in
                if let err = err {
                    self.loginStatusMessage = "Failed to download URL \(err)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url \(url?.absoluteString ?? "")"
                
                guard let url = url else {
                    return
                }
                self.storeUserInformation(email: email, imageProfileURL: url)
            }
        }
    }
    
    private func storeUserInformation(email: String, imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = [
            "email": email,
            "uid": uid,
            "profileImageURL": imageProfileURL.absoluteString
        ]
        FirebaseManager.shared.firestore.collection("users")
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
        }
    }
}
