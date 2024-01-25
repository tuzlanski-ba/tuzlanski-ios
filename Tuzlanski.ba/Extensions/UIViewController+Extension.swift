//
//  UIViewController+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 12. 2023..
//

import UIKit
import SwiftUI

extension UIViewController {
    
    func addSwiftUIView(_ rootView: some View, safely: Bool = false, backgroundColor: UIColor? = .screenBackground) {
        let vc = UIHostingController(rootView: rootView)
        vc.view.backgroundColor = backgroundColor
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        view.addSubview(swiftuiView)
        swiftuiView.pin(to: view, safely: safely)
        vc.didMove(toParent: self)
    }
    
    func embeddedInNavigation() -> UINavigationController {
        let navigation = ThemedNavigationController(rootViewController: self)
        return navigation
    }
    
    func addCloseButton() {
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}
