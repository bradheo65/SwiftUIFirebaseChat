//
//  LoadingMessageViewModifier.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/18.
//

import SwiftUI

struct LoadingMessageViewModifier: ViewModifier {
    private var isLoading: Bool
    @Binding var loadingMessage: String

    init(
        isLoading: Bool,
        loadingMessage: Binding<String>
    ) {
        self.isLoading = isLoading
        self._loadingMessage = loadingMessage
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        content
                            .disabled(self.isLoading)
                        
                        ProgressView(loadingMessage)
                            .controlSize(.regular)
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .background(Color.secondary.opacity(0.3))
                            .opacity(self.isLoading ? 1 : 0)
                    }
                }
            } else {
                content
            }
        }
    }
}
