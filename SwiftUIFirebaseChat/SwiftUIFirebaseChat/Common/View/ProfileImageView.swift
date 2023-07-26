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
