//
//  LoadingViewModifier.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/15.
//

import SwiftUI

struct LoadingViewModifier: ViewModifier {
    private var isLoading: Bool

    init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        content
                            .disabled(self.isLoading)
                        
                        ProgressView()
                            .controlSize(.large)
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
