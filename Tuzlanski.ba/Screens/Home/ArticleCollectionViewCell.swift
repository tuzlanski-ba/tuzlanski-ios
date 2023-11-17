//
//  ArticleCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 12. 11. 2023..
//

import UIKit
import NukeUI

class ArticleCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().forAutoLayout()
        titleLabel.font = .Montserrat(.bold, size: 14)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel().forAutoLayout()
        subtitleLabel.font = .Montserrat(.bold, size: 12)
        subtitleLabel.numberOfLines = 1
        
        return subtitleLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel().forAutoLayout()
        dateLabel.font = .Montserrat(.regular, size: 11)
        dateLabel.textColor = .systemGray2
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
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.spacing = 1
        
        contentView.addSubview(imageView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(dateLabel)
        
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 110),
            imageView.heightAnchor.constraint(equalToConstant: 85),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            contentStackView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10)
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
