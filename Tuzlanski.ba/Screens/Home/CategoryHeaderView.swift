//
//  CategoryHeaderView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 11. 2023..
//

import UIKit

protocol CategoryHeaderViewDelegate: AnyObject {
    func moreButtonPressed(category: Category)
}

class CategoryHeaderView: UICollectionReusableView {
    
    // MARK: - UI Components
    
    private lazy var lineView: UIView = {
        let lineView = UIView().forAutoLayout()
        
        return lineView
    }()

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel().forAutoLayout()
        nameLabel.font = .Montserrat(.bold, size: 24)
        nameLabel.numberOfLines = 1
        
        return nameLabel
    }()
    
    private lazy var moreButton: PillBorderButton = {
        let moreButton = PillBorderButton(title: "VIŠE").forAutoLayout()
        moreButton.addTarget(self, action: #selector(moreButtonPressed), for: .touchUpInside)
        
        return moreButton
    }()
    
    // MARK: - Properties
    
    private var category: Category?
    
    weak var delegate: CategoryHeaderViewDelegate?
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(nameLabel)
        addSubview(moreButton)
        addSubview(lineView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            moreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            lineView.heightAnchor.constraint(equalToConstant: 0.8)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods

    func configure(category: Category) {
        self.category = category
        
        nameLabel.text = category.name
        
        let categoryColor = UIColor(hex: category.color)
        nameLabel.textColor = categoryColor
        lineView.backgroundColor = categoryColor
        moreButton.color = categoryColor
    }
    
    // MARK: - Private methods
    
    @objc private func moreButtonPressed() {
        guard let category else { return }
        delegate?.moreButtonPressed(category: category)
    }
}
