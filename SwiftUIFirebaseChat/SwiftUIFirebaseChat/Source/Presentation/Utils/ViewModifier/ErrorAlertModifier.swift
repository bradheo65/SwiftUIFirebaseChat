//
//  ErrorAlertModifier.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/15.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    private var isPresented: Binding<Bool>
    private let message: String
    
    init(isPresented: Binding<Bool>, message: String) {
        self.isPresented = isPresented
        self.message = message
    }
    
    func body(content: Content) -> some View {
        content.alert(isPresented: isPresented) {
            Alert(
                title: Text("Error"),
                message: Text(message),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }
}
