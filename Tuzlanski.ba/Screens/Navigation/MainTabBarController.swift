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
        setupNotificationHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = self.view.bounds
        tabBarController?.view.addSubview(visualEffectView)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)], for: .selected)
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
    
    private func setupNotificationHandlers() {
        NotificationCenter.observe(notification: .menuCategoryPressed) { [unowned self] notification in
            guard let navigationController = self.selectedViewController as? UINavigationController else { return }
            guard let category = notification.userInfo?["category"] as? Category else { return }
            
            let newestViewController = NewestViewController(category: category)
            navigationController.pushViewController(newestViewController, animated: true)
        }
    }
}
