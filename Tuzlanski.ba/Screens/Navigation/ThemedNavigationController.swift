//
//  ThemedNavigationController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 12. 2023..
//

import UIKit

class ThemedNavigationController: UINavigationController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .label
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Montserrat(.extraBold, size: 16)]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
