//
//  UserAvatarView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 17. 12. 2023..
//

import UIKit

class UserAvatarView: UIView {
    
    private lazy var containerView: UIView = {
        let containerView = UIView().forAutoLayout()
        
        return containerView
    }()
    
    private lazy var initialsLabel: UILabel = {
        let initialsLabel = UILabel().forAutoLayout()
        initialsLabel.font = .Montserrat(.bold, size: 12)
        initialsLabel.textColor = .white
        initialsLabel.numberOfLines = 1
        
        return initialsLabel
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(containerView)
        containerView.pin(to: self)
        
        containerView.addSubview(initialsLabel)
        NSLayoutConstraint.activate([
            initialsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.width / 2
    }
    
    var name: String = "" {
        didSet {
            containerView.backgroundColor = UIColor.color(for: name)
            initialsLabel.text = name.initials
        }
    }
}
