//
//  UIFont+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import UIKit

extension UIFont {

    enum MontserratType: String {
        case semibold = "SemiBold"
        case regular = "Regular"
        case light = "Light"
        case thin = "Thin"
        case extraBold = "ExtraBold"
        case bold = "Bold"
        case black = "Black"
    }

    static func Montserrat(_ type: MontserratType = .regular, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: "Montserrat-\(type.rawValue)", size: size)!
    }
}
