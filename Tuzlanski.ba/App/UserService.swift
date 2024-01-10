//
//  UserService.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 9. 1. 2024..
//

import UIKit

class UserService: NSObject, ApplicationService {
    
    private let httpClient = TuzlanskiHttpClient()
    
    override init() {
        super.init()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard AppStorage.user != nil else { return }
        
        Task {
            do {
                let user = try await httpClient.fetchUserInfo()
                AppStorage.user = user
                NotificationCenter.dispatch(notification: AppNotifications.userChangedNotification)
            } catch {
                print("Fetching user from UserService failed:", error)
            }
        }
    }
}
