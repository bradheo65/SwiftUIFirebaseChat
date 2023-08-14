//
//  RemoteImage.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/02.
//

import SwiftUI

struct RemoteImage: View {
    @ObservedObject var imageLoader: ImageLoader
    
    @Binding var imageData: UIImage?
    @Binding var imageFrame: CGRect?
    @Binding var isImageTap: Bool

    var body: some View {
        if let image = imageLoader.image {
            GeometryReader { reader in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        imageData = image
                        imageFrame = reader.frame(in: .global)
                        isImageTap.toggle()
                    }
            }
        } else {
            ProgressView()
        }
    }
}


final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var url: String
    private var task: URLSessionDataTask?

    init(url: String) {
        self.url = url
        loadImage()
    }

    private func loadImage() {
        if let cachedImage = ImageCache.shared.get(forKey: url) {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: url) else { return }

        task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.image = image
                ImageCache.shared.set(image ?? UIImage(), forKey: self.url)
            }
        }
        task?.resume()
    }
}
