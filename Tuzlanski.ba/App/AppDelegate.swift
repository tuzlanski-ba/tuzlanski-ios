//
//  AppDelegate.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit
import SideMenu
import OneSignalFramework

public protocol ApplicationService: UIApplicationDelegate {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var services: [any ApplicationService] = [
        ConnectivityService(),
        FirebaseService(),
        UserService()
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
        
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("03d993d5-fe52-404e-b32e-c0028343c658", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return true
        }
        
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return false }
        guard let homeNavigationController = tabBarController.viewControllers?[0] as? UINavigationController else { return false }
        guard let path = components.path else { return false }
        
        let url = TuzlanskiHttpClient().host + "articles/" + path.deletingPrefix("/")
        homeNavigationController.pushViewController(ArticleViewController(url: url), animated: true)
        
        return true
    }
}

