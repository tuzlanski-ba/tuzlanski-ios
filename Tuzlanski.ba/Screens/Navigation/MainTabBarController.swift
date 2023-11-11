//
//  MainTabBarController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.tabBar.tintColor = .tintColor
        
        setupViewControllers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = self.view.bounds
        tabBarController?.view.addSubview(visualEffectView)
    }
    
    // MARK: - Private methods
    
    private func setupViewControllers() {
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem.title = "Početna"
        homeViewController.tabBarItem.image = UIImage(systemName: "house")
        
        let newestViewController = NewestViewController()
        newestViewController.tabBarItem.title = "Najnovije"
        newestViewController.tabBarItem.image = UIImage(systemName: "calendar")
        
        let popularViewController = PopularViewController()
        popularViewController.tabBarItem.title = "Najčitanije"
        popularViewController.tabBarItem.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem.title = "Profil"
        profileViewController.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        
        self.viewControllers = [
            SideNavigationController(rootViewController: homeViewController),
            SideNavigationController(rootViewController: newestViewController),
            SideNavigationController(rootViewController: popularViewController),
            SideNavigationController(rootViewController: profileViewController)
        ]
    }
}
