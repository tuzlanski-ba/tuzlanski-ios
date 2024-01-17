//
//  MainTabBarController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

protocol ScrollableViewController {
    func scrollToTop()
}

class MainTabBarController: UITabBarController {
    
    enum Screen: Int {
        case home = 0
        case latest = 1
        case popular = 2
        case profile = 3
    }
    
    // MARK: - Properties
    
    private var previousViewController: UIViewController?

    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
        self.tabBar.tintColor = .label
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)]
        tabBarAppearance.backgroundColor = .screenBackground
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Montserrat(.bold, size: 10)], for: .selected)
        
        setupViewControllers()
        setupNotificationHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Public methods
    
    func show(screen: Screen) {
        self.selectedIndex = screen.rawValue
        (self.viewControllers?[screen.rawValue] as? UINavigationController)?.popToRootViewController(animated: true)
    }
    
    // MARK: - Private methods
    
    private func setupViewControllers() {
        let homeViewController = HomeViewController()
        homeViewController.tabBarItem.title = "Početna"
        homeViewController.tabBarItem.image = UIImage(systemName: "house")
        
        let newestViewController = LatestViewController(fetchDataSource: LatestFetchDataSource())
        newestViewController.tabBarItem.title = "Najnovije"
        newestViewController.tabBarItem.image = UIImage(systemName: "calendar")
        
        let popularViewController = LatestViewController(fetchDataSource: MostReadsFetchDataSource())
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
        
        previousViewController = self.viewControllers?.first
    }
    
    private func setupNotificationHandlers() {
        NotificationCenter.observe(notification: .menuCategoryPressed) { [unowned self] notification in
            guard let navigationController = self.selectedViewController as? UINavigationController else { return }
            guard let category = notification.userInfo?["category"] as? Category else { return }
            
            let newestViewController = LatestViewController(fetchDataSource: CategoryFetchDataSource(category: category))
            navigationController.pushViewController(newestViewController, animated: true)
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if previousViewController == viewController {
            if let scrollableVC = viewController as? ScrollableViewController {
                scrollableVC.scrollToTop()
            } else if let navigationController = viewController as? UINavigationController, navigationController.viewControllers.count == 1 {
                if let scrollableVC = navigationController.viewControllers.first as? ScrollableViewController {
                    scrollableVC.scrollToTop()
                }
            }
        }
        
        previousViewController = viewController
        
        return true
    }
}
