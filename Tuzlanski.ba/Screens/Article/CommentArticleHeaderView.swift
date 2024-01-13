//
//  CommentArticleHeaderView.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 18. 12. 2023..
//

import UIKit
import NukeUI

class CommentArticleHeaderView: UICollectionReusableView {
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().forAutoLayout()
        titleLabel.font = .Montserrat(.bold, size: 14)
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel().forAutoLayout()
        subtitleLabel.font = .Montserrat(.bold, size: 12)
        subtitleLabel.numberOfLines = 1
        
        return subtitleLabel
    }()
    
    private lazy var articleImageView: LazyImageView = {
        let articleImageView = LazyImageView().forAutoLayout()
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.placeholderView = UIActivityIndicatorView()
        articleImageView.priority = .high
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 8
        
        return articleImageView
    }()
    
    // MARK: - Properties
    
    private var article: Article?
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView().forAutoLayout()
        containerView.backgroundColor = .clear
        addSubview(containerView)
        
        backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect).forAutoLayout()
        blurEffectView.backgroundColor = .clear
        containerView.addSubview(blurEffectView)
        blurEffectView.pin(to: containerView)
        
        let contentStackView = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel]).forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.spacing = 2
        contentStackView.alignment = .leading

        containerView.addSubview(articleImageView)
        containerView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            articleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            articleImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            articleImageView.widthAnchor.constraint(equalToConstant: 80),
            articleImageView.heightAnchor.constraint(equalToConstant: 60),
            
            contentStackView.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 12),
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22),
            
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        articleImageView.layer.cornerRadius = 8
    }
    
    // MARK: - Public methods

    func configure(article: Article) {
        self.article = article
        titleLabel.text = article.title
        subtitleLabel.text = article.preTitle?.uppercased() ?? article.section.name.uppercased()
        subtitleLabel.textColor = UIColor(hex: article.section.color_hex)
        articleImageView.url = URL(string: article.image.original ?? "")
    }
}
