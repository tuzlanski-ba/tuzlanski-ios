//
//  SideNavigationController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SideMenu

class SideNavigationController: UINavigationController {
    
    // MARK: - UI Components
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(named: "tuzlanski-logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return logoImageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        navigationBar.tintColor = .tintColor
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view, forMenu: .left)
    }
    
    // MARK: - Private methods
    
    @objc private func openSideMenu() {
        guard let leftMenuViewController = SideMenuManager.default.leftMenuNavigationController else { return }
        present(leftMenuViewController, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension SideNavigationController: UINavigationControllerDelegate {
    
    // In this delegate method the goal is to set side menu icon and the logo on first view controller.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewControllers.first == viewController && viewController.navigationItem.title?.isEmpty ?? true {
            viewController.navigationItem.titleView = logoImageView
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(openSideMenu))
        }
    }
}
