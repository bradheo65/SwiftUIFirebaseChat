//
//  ProfileImageView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import SwiftUI

struct ProfileImageView: View {
    let url: String
    
    var body: some View {
        AsyncImage(
            url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .failure(_):
                    Image(systemName: "person.fill")
                        .foregroundColor(.black)
                case .success(let image):
                    image.resizable()
                @unknown default:
                    EmptyView()
                }
            }
            .scaledToFit()
            .shadow(radius: 5)
    }
}

struct ProfileImageView2: View {
    @Binding var image: Image
    let url: String
    
    var body: some View {
        AsyncImage(
            url: URL(string: url)) { phase in
                if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Color.red // Indicates an error.
                    } else {
                        Color.blue // Acts as a placeholder.
                    }
            }
            .scaledToFit()
            .shadow(radius: 5)
    }
    
    func getImage() {
        
    }
}
