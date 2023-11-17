//
//  UIView+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

extension UIView {
    
    /// Creates view with the size of the device's screen. These views are used for UIViewController views.
    static func screen() -> UIView {
        return UIView(frame: UIScreen.main.bounds)
    }
    
    func forAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func pin(to view: UIView, safely: Bool = false, padding: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: (safely ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor), constant: padding.top),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding.right),
            bottomAnchor.constraint(equalTo: (safely ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor), constant: padding.bottom),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left)
        ])
    }
}
