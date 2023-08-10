//
//  ImageSaveService.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import SwiftUI

final class ImageSaveService: NSObject {
    static let shared = ImageSaveService()
    
    private override init() { }
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

}

extension ImageSaveService {
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
    
}
