//
//  ImageViewer.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/28.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var uIimage: UIImage?
    @Binding var show: Bool
    @Binding var end: Bool
    @State private var imageURL2: String = ""

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                Image(uiImage: uIimage ?? UIImage())
                    .resizable()
                    .scaledToFit()
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
                    .onTapGesture {
                        Task {
                            await animate(duration: 0.2, {
                                show.toggle()
                            })
                            end.toggle()
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}
