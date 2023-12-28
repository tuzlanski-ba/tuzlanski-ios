//
//  FirebaseService.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 28. 12. 2023..
//

import Foundation
import FirebaseCore
import UIKit

class FirebaseService: NSObject, ApplicationService {
    
    // MARK: - ApplicationService
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
