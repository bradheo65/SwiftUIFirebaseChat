//
//  LoadingView.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 10/24/23.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                content()
                    .disabled(self.isShowing)
                
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .background(Color(uiColor: .secondaryLabel).opacity(0.5))
                    .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}
