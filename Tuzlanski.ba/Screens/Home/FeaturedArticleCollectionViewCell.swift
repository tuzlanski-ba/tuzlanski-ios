//
//  FeaturedArticleCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import UIKit
import NukeUI

class FeaturedArticleCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().forAutoLayout()
        titleLabel.font = .Montserrat(.bold, size: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 3
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel().forAutoLayout()
        subtitleLabel.font = .Montserrat(.bold, size: 13)
        subtitleLabel.numberOfLines = 1
        
        return subtitleLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel().forAutoLayout()
        dateLabel.font = .Montserrat(.regular, size: 11)
        dateLabel.textColor = .systemGray4
        dateLabel.numberOfLines = 1
        
        return dateLabel
    }()
    
    private lazy var imageView: LazyImageView = {
        let imageView = LazyImageView().forAutoLayout()
        imageView.contentMode = .scaleAspectFill
        imageView.placeholderView = UIActivityIndicatorView()
        imageView.priority = .high
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView().forAutoLayout()
        containerView.layer.cornerRadius = 8
        
        contentView.addSubview(containerView)
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.spacing = 3
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        let gradientView = GradientView().forAutoLayout()
        gradientView.layer.cornerRadius = 8
        
        containerView.addSubview(imageView)
        containerView.addSubview(gradientView)
        containerView.addSubview(contentStackView)
        
        imageView.pin(to: containerView)
        gradientView.pin(to: containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.heightAnchor.constraint(equalToConstant: ceil((UIScreen.main.bounds.width - 16 - 16) / 4 * 3)),
            
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.reset()
    }
    
    // MARK: - Public methods
    
    func configure(article: ListArticle) {
        titleLabel.text = article.title
        subtitleLabel.text = article.preTitle?.uppercased() ?? article.section.name.uppercased()
        subtitleLabel.textColor = UIColor(hex: article.section.color_hex)
        imageView.url = URL(string: article.image.original)
        dateLabel.text = Date.format(apiDate: article.publishedAt)
    }
}

class GradientView: UIView {
    
    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        let topColor: UIColor = .clear
        let bottomColor: UIColor = .black
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
        layer.locations = [0,1]
        return layer
    }()
    
    init() {
        super.init(frame: .zero)
        gradient.frame = frame
        layer.insertSublayer(gradient, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
    }
}
