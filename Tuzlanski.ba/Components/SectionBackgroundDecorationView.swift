//
//  SectionBackgroundDecorationView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 14. 1. 2024..
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
    
    static let kind = "background-element-kind"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .screenBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
