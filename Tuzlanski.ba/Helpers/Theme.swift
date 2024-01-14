//
//  Theme.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 11. 11. 2023..
//

import UIKit

// MARK: - App colors

extension UIColor {
    
    static var tintColor: UIColor {
        return UIColor(hex: "#EF4833")
    }
    
    static var screenBackground: UIColor {
        return .dynamicColor(light: .white, dark: .tuzlanskiDarkBlue)
    }
    
    static var tuzlanskiDarkBlue: UIColor {
        return UIColor(hex: "#091425")
    }
    
    static var secondaryBackground: UIColor {
        return .dynamicColor(light: .systemGray6, dark: UIColor(hex: "#0d1d36"))
    }
}
