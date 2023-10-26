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
        ZStack(alignment: .topLeading) {
            ZoomInImageView(
                uiimage: uIimage ?? UIImage()
            )
                .ignoresSafeArea()
                .onTapGesture {
                    showButtons.toggle()
                }
            if showButtons {
                contentButtonView
            }
        }
    }
}

extension ImageViewer {
    private var contentButtonView: some View {
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
        .padding()
    }
}
