//
//  CommentCollectionViewCell.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 12. 2023..
//

import UIKit

protocol CommentCollectionViewCellDelegate: AnyObject {
    func upvoted(comment: Comment)
    func downvoted(comment: Comment)
    func reply(comment: Comment)
    func report(comment: Comment)
}

class CommentCollectionViewCell: UICollectionViewCell {
    
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
    
    private lazy var reportButton: UIButton = {
        let reportButton = UIButton(type: .system).forAutoLayout()
        reportButton.configuration = UIButton.Configuration.plain()
        reportButton.configuration?.image = UIImage(named: "report")?.resized(to: CGSize(width: 17, height: 17))
        reportButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .tintColor }
        reportButton.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.alpha = 0.5
            default:
                button.alpha = 1
            }
        }
        reportButton.addTarget(self, action: #selector(reportButtonPressed), for: .touchUpInside)
        
        return reportButton
    }()
    
    private lazy var upvoteButton: UIButton = {
        let upvoteButton = UIButton(type: .system).forAutoLayout()
        upvoteButton.configuration = UIButton.Configuration.plain()
        upvoteButton.configuration?.image = UIImage(named: "upvote")?.resized(to: CGSize(width: 18, height: 18))
        upvoteButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .systemGreen }
        upvoteButton.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.alpha = 0.5
            default:
                button.alpha = 1
            }
        }
        upvoteButton.addTarget(self, action: #selector(upvoteButtonPressed), for: .touchUpInside)
        
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
        downvoteButton.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.alpha = 0.5
            default:
                button.alpha = 1
            }
        }
        downvoteButton.addTarget(self, action: #selector(downvoteButtonPressed), for: .touchUpInside)
        
        return downvoteButton
    }()
    
    private lazy var downvoteLabel: UILabel = {
        let downvoteLabel = UILabel().forAutoLayout()
        downvoteLabel.font = .Montserrat(.bold, size: 14)
        downvoteLabel.textColor = .label
        downvoteLabel.numberOfLines = 1
        
        return downvoteLabel
    }()
    
    private lazy var replyButton: UIButton = {
        let replyButton = UIButton(type: .system).forAutoLayout()
        replyButton.configuration = UIButton.Configuration.plain()
        replyButton.configuration?.image = UIImage(named: "reply")?.resized(to: CGSize(width: 17, height: 17))
        replyButton.configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in .tintColor }
        replyButton.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.alpha = 0.5
            default:
                button.alpha = 1
            }
        }
        replyButton.addTarget(self, action: #selector(replyButtonPressed), for: .touchUpInside)
        
        return replyButton
    }()
    
    private var containerViewLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    
    private var comment: Comment?
    
    weak var delegate: CommentCollectionViewCellDelegate?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let containerView = UIView().forAutoLayout()
        containerView.backgroundColor = .systemGray6
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
        contentView.addSubview(reportButton)
        contentView.addSubview(replyButton)
        
        contentStackView.pin(to: containerView, padding: UIEdgeInsets(top: 10, left: 10, bottom: -10, right: -10))
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            userAvatarView.widthAnchor.constraint(equalToConstant: 32),
            userAvatarView.heightAnchor.constraint(equalTo: userAvatarView.widthAnchor),
            
            reportButton.widthAnchor.constraint(equalToConstant: 24),
            reportButton.heightAnchor.constraint(equalTo: reportButton.widthAnchor),
            reportButton.centerYAnchor.constraint(equalTo: metaDataStackView.centerYAnchor),
            reportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            upvoteButton.widthAnchor.constraint(equalToConstant: 24),
            upvoteButton.heightAnchor.constraint(equalTo: upvoteButton.widthAnchor),
            
            downvoteButton.widthAnchor.constraint(equalToConstant: 24),
            downvoteButton.heightAnchor.constraint(equalTo: downvoteButton.widthAnchor),
            
            replyButton.widthAnchor.constraint(equalToConstant: 24),
            replyButton.heightAnchor.constraint(equalTo: replyButton.widthAnchor),
            replyButton.centerYAnchor.constraint(equalTo: actionsStackView.centerYAnchor),
            replyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        containerViewLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        containerViewLeadingConstraint?.isActive = true
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
    
    func configure(comment: Comment) {
        self.comment = comment
        userAvatarView.name = comment.name
        nameLabel.text = comment.name
        contentLabel.text = comment.content
        dateLabel.text = ""
        if let date = Date.date(apiDate: comment.created_at) {
            dateLabel.text = Date.formatRelativeDate(date)
        }
        upvoteLabel.text = String(comment.upvotes)
        downvoteLabel.text = String(comment.downvotes)
        
        containerViewLeadingConstraint?.constant = comment.thread_id == 0 ? 16 : 40
        contentView.relayout()
    }
    
    // MARK: - Private methods
    
    @objc private func upvoteButtonPressed() {
        guard let comment else { return }
        delegate?.upvoted(comment: comment)
    }
    
    @objc private func downvoteButtonPressed() {
        guard let comment else { return }
        delegate?.downvoted(comment: comment)
    }
    
    @objc private func replyButtonPressed() {
        guard let comment else { return }
        delegate?.reply(comment: comment)
    }
    
    @objc private func reportButtonPressed() {
        guard let comment else { return }
        delegate?.report(comment: comment)
    }
}
