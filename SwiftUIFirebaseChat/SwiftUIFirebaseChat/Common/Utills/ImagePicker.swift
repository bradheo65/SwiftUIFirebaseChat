//
//  ImagePicker.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var videoUrl: URL?

    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.parent.videoUrl = videoUrl
            }
            parent.image = info[.originalImage] as? UIImage

            picker.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.allowsEditing = true
        controller.delegate = context.coordinator
        controller.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
