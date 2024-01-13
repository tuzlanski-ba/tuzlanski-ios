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
        dateLabel.font = .Montserrat(.semibold, size: 11)
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
    
    private lazy var galleryContainerView: UIView = {
        let galleryContainerView = UIView().forAutoLayout()
        galleryContainerView.backgroundColor = .tintColor
        galleryContainerView.round(corners: [.topLeft, .bottomRight], radius: 8)
        
        let galleryImageView = UIImageView().forAutoLayout()
        galleryImageView.image = UIImage(named: "camera")
        galleryImageView.contentMode = .scaleAspectFit
        galleryImageView.tintColor = .white
        NSLayoutConstraint.activate([
            galleryImageView.widthAnchor.constraint(equalToConstant: 17),
            galleryImageView.heightAnchor.constraint(equalTo: galleryImageView.heightAnchor)
        ])
        
        galleryContainerView.addSubview(galleryImageView)
        galleryImageView.pin(to: galleryContainerView, padding: .init(top: 3, left: 7, bottom: -3, right: -7))
        
        return galleryContainerView
    }()
    
    private lazy var commentCountLabel: UILabel = {
        let commentCountLabel = UILabel().forAutoLayout()
        commentCountLabel.font = .Montserrat(.bold, size: 11)
        commentCountLabel.textColor = .systemGray2
        commentCountLabel.numberOfLines = 1
        
        return commentCountLabel
    }()
    
    private lazy var commentStackView: UIStackView = {
        let commentStackView = UIStackView().forAutoLayout()
        commentStackView.alignment = .center
        commentStackView.axis = .horizontal
        commentStackView.spacing = 4
        
        let imageView = UIImageView(image: UIImage(named: "comments")).forAutoLayout()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray2
        
        commentStackView.addArrangedSubview(imageView)
        commentStackView.addArrangedSubview(commentCountLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 15),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        return commentStackView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView().forAutoLayout()
        containerView.layer.cornerRadius = 8
        
        contentView.addSubview(containerView)
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.spacing = 5
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(dateLabel)
        
        let gradientView = GradientView().forAutoLayout()
        gradientView.layer.cornerRadius = 8
        
        containerView.addSubview(imageView)
        containerView.addSubview(gradientView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(galleryContainerView)
        containerView.addSubview(commentStackView)
        
        imageView.pin(to: containerView)
        gradientView.pin(to: containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).with(priority: .defaultHigh),
            containerView.heightAnchor.constraint(equalToConstant: ceil((UIScreen.main.bounds.width - 16 - 16) / 4 * 3)),
            
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            galleryContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            galleryContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            commentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            commentStackView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 8
        galleryContainerView.relayout()
        galleryContainerView.round(corners: [.topLeft, .bottomRight], radius: 8)
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
        imageView.url = URL(string: article.image.original ?? "")
        dateLabel.text = Date.format(apiDate: article.publishedAt)
        galleryContainerView.isHidden = !article.isGallery.bool
        galleryContainerView.backgroundColor = UIColor(hex: article.section.color_hex)
        commentStackView.isHidden = article.commentsCount == 0
        commentCountLabel.text = String(article.commentsCount)
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
