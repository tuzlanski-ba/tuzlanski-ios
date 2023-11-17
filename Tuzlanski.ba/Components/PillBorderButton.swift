//
//  PillBorderButton.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 11. 2023..
//

import UIKit

class PillBorderButton: UIControl {
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().forAutoLayout()
        titleLabel.font = .Montserrat(.extraBold, size: 12)
        titleLabel.numberOfLines = 1
        
        return titleLabel
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView().forAutoLayout()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "arrow-right")
        iconImageView.tintColor = .label
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 14),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
        
        return iconImageView
    }()
    
    var color: UIColor? {
        didSet {
            layer.borderColor = color?.cgColor
        }
    }
    
    // MARK: - Lifecycle
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 0.8
        layer.cornerRadius = 12
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .horizontal
        contentStackView.spacing = 3
        contentStackView.alignment = .center
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.isUserInteractionEnabled = false
        
        addSubview(contentStackView)
        contentStackView.pin(to: self, padding: .init(top: 8, left: 12, bottom: -8, right: -12))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = self.isHighlighted ? 0.6 : 1.0
        }
    }
}
