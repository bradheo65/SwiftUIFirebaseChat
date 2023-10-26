//
//  ZoomInImageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 10/26/23.
//

import SwiftUI


struct ZoomInImageView: UIViewControllerRepresentable {
    let uiimage: UIImage
    
    func makeUIViewController(context: Context) -> ZoomInImageViewController {
        let zoomInImageViewController = ZoomInImageViewController()
        zoomInImageViewController.configure(image: uiimage)
        
        return zoomInImageViewController
    }

    func updateUIViewController(_ uiViewController: ZoomInImageViewController, context: Context) {

    }
}

import UIKit

final class ZoomInImageViewController: UIViewController {
    private let imageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.contentMode = .scaleAspectFit
        uiImageView.clipsToBounds = true

        return uiImageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = .black

        return scrollView
    }()
    
    override func viewDidLoad() {
        addSubView()
        setupUIConstraints()
        
        scrollView.delegate = self
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }
        
    func configure(image: UIImage) {
        imageView.image = image
    }

    private func addSubView() {
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
    }
    
    private func setupUIConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.frame.width),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.height),
        ])
    }
}

extension ZoomInImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= 1.0 {
            scrollView.zoomScale = 1.0
        }
        
        if scrollView.zoomScale >= 2.0 {
            scrollView.zoomScale = 2.0
        }
    }
}

#Preview {
    ZoomInImageView(uiimage: UIImage(systemName: "photo")?.withTintColor(.gray, renderingMode: .alwaysOriginal) ?? UIImage())
        .ignoresSafeArea()
}
