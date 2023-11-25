//
//  AppDelegate.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SideMenu

public protocol ApplicationService: UIApplicationDelegate {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var services: [any ApplicationService] = [
        ConnectivityService()
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let leftMenuNavigationController = SideMenuNavigationController(rootViewController: CategoriesMenuViewController())
        SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        // Inject MainTabBarController as ViewController that Connectivity service can use to present connection alerts.
        // NOTE: Do not change the order of Connectivity service in AppDelegate services.
        (services[0] as? ConnectivityService)?.viewControllerForAlertPresentation = window?.rootViewController
        
        for service in services {
            _ = service.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for service in services {
            service.applicationDidBecomeActive?(application)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for service in services {
            service.applicationDidEnterBackground?(application)
        }
    }
}

