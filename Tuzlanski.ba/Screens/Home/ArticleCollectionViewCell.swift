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
        dateLabel.font = .Montserrat(.semibold, size: 11)
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
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel().forAutoLayout()
        timeLabel.font = .Montserrat(.bold, size: 11)
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 1
        
        return timeLabel
    }()
    
    private lazy var timeContainerView: UIView = {
        let timeContainerView = UIView().forAutoLayout()
        timeContainerView.backgroundColor = .tintColor
        timeContainerView.round(corners: [.topLeft, .bottomRight], radius: 8)
        
        let clockImageView = UIImageView().forAutoLayout()
        clockImageView.image = UIImage(named: "clock")
        clockImageView.contentMode = .scaleAspectFit
        clockImageView.tintColor = .white
        NSLayoutConstraint.activate([
            clockImageView.widthAnchor.constraint(equalToConstant: 12),
            clockImageView.heightAnchor.constraint(equalTo: clockImageView.widthAnchor)
        ])
        
        let stackView = UIStackView().forAutoLayout()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        
        stackView.addArrangedSubview(clockImageView)
        stackView.addArrangedSubview(timeLabel)
        
        timeContainerView.addSubview(stackView)
        
        stackView.pin(to: timeContainerView, padding: UIEdgeInsets(top: 6, left: 6, bottom: -6, right: -6))
        
        return timeContainerView
    }()
    
    private lazy var galleryContainerView: UIView = {
        let galleryContainerView = UIView().forAutoLayout()
        galleryContainerView.backgroundColor = .tintColor
        galleryContainerView.round(corners: [.bottomLeft, .topRight], radius: 8)
        
        let galleryImageView = UIImageView().forAutoLayout()
        galleryImageView.image = UIImage(named: "camera")
        galleryImageView.contentMode = .scaleAspectFit
        galleryImageView.tintColor = .white
        NSLayoutConstraint.activate([
            galleryImageView.widthAnchor.constraint(equalToConstant: 14),
            galleryImageView.heightAnchor.constraint(equalTo: galleryImageView.heightAnchor)
        ])
        
        galleryContainerView.addSubview(galleryImageView)
        galleryImageView.pin(to: galleryContainerView, padding: .init(top: 3, left: 6, bottom: -3, right: -6))
        
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
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.spacing = 1
        
        contentView.addSubview(imageView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(timeContainerView)
        contentView.addSubview(galleryContainerView)
        contentView.addSubview(commentStackView)
        
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 110),
            imageView.heightAnchor.constraint(equalToConstant: 85),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).with(priority: .defaultHigh),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            contentStackView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            
            timeContainerView.topAnchor.constraint(equalTo: imageView.topAnchor),
            timeContainerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            galleryContainerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            galleryContainerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            commentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            commentStackView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 8
        timeContainerView.relayout()
        timeContainerView.round(corners: [.topLeft, .bottomRight], radius: 8)
        galleryContainerView.relayout()
        galleryContainerView.round(corners: [.bottomLeft, .topRight], radius: 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.reset()
    }
    
    // MARK: - Public methods
    
    func configure(article: ListArticle, displayTimeOnImage: Bool = false) {
        titleLabel.text = article.title
        subtitleLabel.text = article.preTitle?.uppercased() ?? article.section.name.uppercased()
        subtitleLabel.textColor = UIColor(hex: article.section.color_hex)
        imageView.url = URL(string: article.image.original)
        dateLabel.text = Date.format(apiDate: article.publishedAt)
        timeLabel.text = Date.formatToTime(apiDate: article.publishedAt)
        timeContainerView.isHidden = displayTimeOnImage == false
        timeContainerView.backgroundColor = UIColor(hex: article.section.color_hex)
        galleryContainerView.isHidden = !article.isGallery.bool
        galleryContainerView.backgroundColor = UIColor(hex: article.section.color_hex)
        commentStackView.isHidden = article.commentsCount == 0
        commentCountLabel.text = String(article.commentsCount)
    }
    
    var isCommentCountVisible: Bool = true {
        didSet {
            commentStackView.isHidden = !isCommentCountVisible
        }
    }
}
