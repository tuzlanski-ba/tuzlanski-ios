//
//  UserCommentCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 22. 12. 2023..
//

import UIKit

class UserCommentCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var userAvatarView: UserAvatarView = {
        let userAvatarView = UserAvatarView().forAutoLayout()
        
        return userAvatarView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel().forAutoLayout()
        nameLabel.font = .Montserrat(.bold, size: 13)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        
        return nameLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel().forAutoLayout()
        dateLabel.font = .Montserrat(.semibold, size: 12)
        dateLabel.textColor = .systemGray2
        dateLabel.numberOfLines = 1
        
        return dateLabel
    }()
    
    private lazy var contentLabel: UILabel = {
        let dateLabel = UILabel().forAutoLayout()
        dateLabel.font = .Montserrat(.semibold, size: 14)
        dateLabel.textColor = .label
        dateLabel.numberOfLines = 0
        
        return dateLabel
    }()
    
    private lazy var openButton: UIButton = {
        let openButton = UIButton(type: .system).forAutoLayout()
        openButton.configuration = UIButton.Configuration.plain()
        openButton.configuration?.image = UIImage(named: "arrow-right")?.resized(to: CGSize(width: 17, height: 17))
        openButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .tintColor }
        openButton.isUserInteractionEnabled = false
        
        return openButton
    }()
    
    private lazy var upvoteButton: UIButton = {
        let upvoteButton = UIButton(type: .system).forAutoLayout()
        upvoteButton.configuration = UIButton.Configuration.plain()
        upvoteButton.configuration?.image = UIImage(named: "upvote")?.resized(to: CGSize(width: 18, height: 18))
        upvoteButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .systemGreen }
        upvoteButton.isUserInteractionEnabled = false
        
        return upvoteButton
    }()
    
    private lazy var upvoteLabel: UILabel = {
        let upvoteLabel = UILabel().forAutoLayout()
        upvoteLabel.font = .Montserrat(.bold, size: 14)
        upvoteLabel.textColor = .label
        upvoteLabel.numberOfLines = 1
        
        return upvoteLabel
    }()
    
    private lazy var downvoteButton: UIButton = {
        let downvoteButton = UIButton(type: .system).forAutoLayout()
        downvoteButton.configuration = UIButton.Configuration.plain()
        downvoteButton.configuration?.image = UIImage(named: "downvote")?.resized(to: CGSize(width: 18, height: 18))
        downvoteButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .systemRed }
        downvoteButton.isUserInteractionEnabled = false
        
        return downvoteButton
    }()
    
    private lazy var downvoteLabel: UILabel = {
        let downvoteLabel = UILabel().forAutoLayout()
        downvoteLabel.font = .Montserrat(.bold, size: 14)
        downvoteLabel.textColor = .label
        downvoteLabel.numberOfLines = 1
        
        return downvoteLabel
    }()
    
    // MARK: - Properties
    
    private var comment: UserCommentsResponse.UserComment?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView().forAutoLayout()
        containerView.backgroundColor = .secondaryBackground
        containerView.layer.cornerRadius = 10
        
        let metaDataStackView = UIStackView().forAutoLayout()
        metaDataStackView.axis = .vertical
        metaDataStackView.alignment = .leading
        metaDataStackView.spacing = 2
        metaDataStackView.addArrangedSubview(nameLabel)
        metaDataStackView.addArrangedSubview(dateLabel)
        
        let headerStackView = UIStackView().forAutoLayout()
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 8
        headerStackView.addArrangedSubview(userAvatarView)
        headerStackView.addArrangedSubview(metaDataStackView)
        
        let actionsStackView = UIStackView().forAutoLayout()
        actionsStackView.axis = .horizontal
        actionsStackView.alignment = .center
        actionsStackView.spacing = 4
        actionsStackView.addArrangedSubview(upvoteButton)
        actionsStackView.addArrangedSubview(upvoteLabel)
        actionsStackView.addArrangedSubview(downvoteButton)
        actionsStackView.addArrangedSubview(downvoteLabel)
        actionsStackView.setCustomSpacing(16, after: upvoteLabel)
        
        let contentStackView = UIStackView().forAutoLayout()
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = 1
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(actionsStackView)
        contentStackView.setCustomSpacing(12, after: headerStackView)
        contentStackView.setCustomSpacing(12, after: contentLabel)
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        contentView.addSubview(openButton)
        
        contentStackView.pin(to: containerView, padding: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -36))
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            userAvatarView.widthAnchor.constraint(equalToConstant: 32),
            userAvatarView.heightAnchor.constraint(equalTo: userAvatarView.widthAnchor),
            
            openButton.widthAnchor.constraint(equalToConstant: 24),
            openButton.heightAnchor.constraint(equalTo: openButton.widthAnchor),
            openButton.centerYAnchor.constraint(equalTo: metaDataStackView.centerYAnchor),
            openButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            upvoteButton.widthAnchor.constraint(equalToConstant: 24),
            upvoteButton.heightAnchor.constraint(equalTo: upvoteButton.widthAnchor),
            
            downvoteButton.widthAnchor.constraint(equalToConstant: 24),
            downvoteButton.heightAnchor.constraint(equalTo: downvoteButton.widthAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public methods
    
    func configure(comment: UserCommentsResponse.UserComment) {
        self.comment = comment
        userAvatarView.name = comment.name
        nameLabel.text = comment.article.title
        contentLabel.text = comment.content
        dateLabel.text = ""
        if let date = Date.date(apiDate: comment.created_at) {
            dateLabel.text = Date.formatRelativeDate(date)
        }
        upvoteLabel.text = String(comment.upvotes)
        downvoteLabel.text = String(comment.downvotes)
    }
}
