//
//  UICollectionView+Extension.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 27. 12. 2023..
//

import UIKit

extension UICollectionView {
    
    func internal_reload() {
        UIView.setAnimationsEnabled(false)
        self.refreshControl?.endRefreshing()
        self.reloadData()
        UIView.setAnimationsEnabled(true)
    }
}
