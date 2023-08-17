//
//  ImageViewer.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/28.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showButtons = false
    
    @Binding var uIimage: UIImage?
    @Binding var show: Bool
    @Binding var hide: Bool
    @Binding var savePhoto: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                ZStack {
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
                    if showButtons {
                        contentButtonView
                    }
                }
                .onTapGesture {
                    showButtons.toggle()
                }
            }
        }
    }
}

extension ImageViewer {
    private var contentButtonView: some View {
        VStack {
            HStack {
                Button {
                    Task {
                        await animate(duration: 0.2, {
                            show.toggle()
                        })
                        hide.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
                Spacer()
                
                Button {
                    savePhoto.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
    }
}
