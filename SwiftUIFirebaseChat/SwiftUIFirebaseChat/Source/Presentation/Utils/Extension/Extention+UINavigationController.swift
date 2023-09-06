//
//  Extention+UINavigationController.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/09/06.
//

import SwiftUI

// Swipe-back 가능하게 하기
extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
