//
//  UIKit+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import UIKit

extension UITableViewCell {
    
    @objc static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    
    @objc static var identifier: String {
        return String(describing: self)
    }
}
