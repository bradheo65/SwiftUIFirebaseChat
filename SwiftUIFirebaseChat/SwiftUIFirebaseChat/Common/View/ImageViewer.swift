//
//  ImageViewer.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/28.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var imageURL: String
        
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ProfileImageView(url: imageURL)
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                    .clipShape(Rectangle())
                    .modifier(
                        ImageModifier(
                            contentSize: CGSize(
                                width: proxy.size.width,
                                height: proxy.size.height
                            )
                        )
                    )
            }
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                            }
                            .padding()
                        
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}


struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(imageURL: .constant(""))
    }
}
