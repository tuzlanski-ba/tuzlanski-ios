//
//  NSLayoutConstraint+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 4. 1. 2024..
//

import UIKit

extension NSLayoutConstraint {
    
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
