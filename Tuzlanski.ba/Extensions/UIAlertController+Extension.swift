//
//  UIAlertController+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 12. 2023..
//

import UIKit

extension UIAlertController {
    
    static func make(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Zatvori", style: .cancel))
        return alert
    }
}
