//
//  ConnectivityService.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 11. 2023..
//

import Foundation
import Connectivity
import UIKit

class ConnectivityService: NSObject, ApplicationService {
    
    // MARK: - Properties
    
    private let connectivity: Connectivity = Connectivity()
    weak var viewControllerForAlertPresentation: UIViewController?
    
    // MARK: - ApplicationService
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        connectivity.framework = .network
        
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
             self?.updateConnectionStatus(connectivity.status)
        }
        
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectivity.startNotifier()
        
        connectivity.checkConnectivity { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        connectivity.stopNotifier()
    }
    
    // MARK: - Private methods
    
    func updateConnectionStatus(_ status: Connectivity.Status) {
        
        if status == .notConnected {
            let alert = UIAlertController(title: "Greška prilikom dohvatanja podataka", message: "Trenutno nemate uključen WiFi ili mobilne podatke. Aplikacija neće moći dohvatati nove podatke.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Postavke", style: .default, handler: { _ in
                guard let url = URL(string: "App-prefs:root=MOBILE_DATA_SETTINGS_ID") else { return }
                UIApplication.shared.open(url)
            }))
            alert.addAction(UIAlertAction(title: "Zatvori", style: .cancel, handler: nil))
            viewControllerForAlertPresentation?.present(alert, animated: true)
        }
    }
}
