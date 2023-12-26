//
//  CommentsViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 16. 12. 2023..
//

import UIKit

class CommentsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.headerTopPadding = 0
            configuration.headerMode = .supplementary
            
            return .list(using: configuration, layoutEnvironment: environment)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)
        collectionView.register(CommentArticleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentArticleHeaderView.identifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private let article: Article
    private var comments: [Comment] = []
    private var page = 0
    private var isFetching = false
    private var canFetchMore = true
    private let commentVoteRepository = CommentVoteRepository()
    
    // MARK: - Lifecycle
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Komentari (\(article.commentsCount))"
        
        let newCommentBarButtonItem = UIBarButtonItem(image: UIImage(named: "new-comment")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(newCommentButtonPressed))
        self.navigationItem.rightBarButtonItem = newCommentBarButtonItem
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if comments.isEmpty {
            collectionView.refreshControl?.beginRefreshing()
            loadNextPage()
        }
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .primaryBackground
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    // MARK: - Public methods
    
    func addPostedComment(_ comment: Comment) {
        comments.insert(comment, at: 0)
        collectionView.reloadData()
    }
    
    // MARK: - Private methods
    
    private func loadNextPage() {
        guard !isFetching && canFetchMore else { return }
        isFetching = true
        Task {
            do {
                page += 1
                let comments = try await httpClient.getLatestComments(page: page, articleID: article.id).reduce(into: [Comment]()) { partialResult, comment in
                    partialResult += [comment] + (comment.subcomments ?? [])
                }
                
                if comments.count < TuzlanskiHttpClient.pageLimit {
                    canFetchMore = false
                }
                
                await MainActor.run {
                    self.comments.append(contentsOf: comments)
                    collectionView.reloadData()
                    collectionView.refreshControl?.endRefreshing()
                    isFetching = false
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func reloadData(refreshControl: UIRefreshControl) {
        isFetching = true
        canFetchMore = true
        page = 0
        
        Task {
            do {
                page += 1
                let comments = try await httpClient.getLatestComments(page: page, articleID: article.id).reduce(into: [Comment]()) { partialResult, comment in
                    partialResult += [comment] + (comment.subcomments ?? [])
                }
                
                if comments.count < TuzlanskiHttpClient.pageLimit {
                    canFetchMore = false
                }
                
                await MainActor.run {
                    self.comments = comments
                    collectionView.reloadData()
                    isFetching = false
                    refreshControl.endRefreshing()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func canPerformActions() -> Bool {
        guard let user = AppStorage.user else { return false }
        return user.has_verified_email
    }
    
    @objc private func newCommentButtonPressed() {
        guard canPerformActions() else {
            present(UIAlertController.make(title: nil, message: "Da biste mogli objaviti komentar morate biti prijavljeni."), animated: true)
            return
        }
        
        showAddNewCommentScreen()
    }
    
    private func showAddNewCommentScreen(replyToComment: Comment? = nil) {
        let newCommentViewController = NewCommentViewController(article: article, replyToComment: replyToComment)
        newCommentViewController.onNewComment = { [weak self] comment in self?.addPostedComment(comment) }
        present(newCommentViewController.embeddedInNavigation(), animated: true)
    }
}

// MARK: - UICollectionView delegates

extension CommentsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if comments.count - 5 == indexPath.row {
            loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.identifier, for: indexPath) as! CommentCollectionViewCell
        cell.delegate = self
        cell.configure(comment: comments[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentArticleHeaderView.identifier, for: indexPath) as! CommentArticleHeaderView
        
        headerView.configure(article: article)
        
        return headerView
    }
}

// MARK: - CommentCollectionViewCellDelegate

extension CommentsViewController: CommentCollectionViewCellDelegate {
    
    func upvoted(comment: Comment) {
        
        guard commentVoteRepository.commentVote(articleID: article.id, commentID: comment.id) == nil else {
            present(UIAlertController.make(title: nil, message: "Već ste glasali za ovaj komentar."), animated: true)
            return
        }
        
        Task {
            do {
                let comment = try await httpClient.upvote(comment: comment)
                
                let commentVote = CommentVote(article_id: article.id, comment_id: comment.id, type: .upvote)
                try? commentVoteRepository.save(commentVote: commentVote)
                
                await MainActor.run {
                    guard let index = comments.firstIndex(where: { $0.id == comment.id }) else { return }
                    var comments = self.comments
                    comments[index] = comment
                    
                    self.comments = comments
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            } catch {
                print("Error:", error)
            }
        }
    }
    
    func downvoted(comment: Comment) {
        
        guard commentVoteRepository.commentVote(articleID: article.id, commentID: comment.id) == nil else {
            present(UIAlertController.make(title: nil, message: "Već ste glasali za ovaj komentar."), animated: true)
            return
        }
        
        Task {
            do {
                let comment = try await httpClient.downvote(comment: comment)
                
                let commentVote = CommentVote(article_id: article.id, comment_id: comment.id, type: .downvote)
                try? commentVoteRepository.save(commentVote: commentVote)
                
                await MainActor.run {
                    guard let index = comments.firstIndex(where: { $0.id == comment.id }) else { return }
                    var comments = self.comments
                    comments[index] = comment
                    
                    self.comments = comments
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            } catch {
                print("Error:", error)
            }
        }
    }
    
    func reply(comment: Comment) {
        guard canPerformActions() else {
            present(UIAlertController.make(title: nil, message: "Da biste mogli odgovoriti na komentar morate biti prijavljeni."), animated: true)
            return
        }
        
        showAddNewCommentScreen(replyToComment: comment)
    }
    
    func report(comment: Comment) {
        let commentReportViewController = CommentReportViewController(comment: comment)
        present(commentReportViewController.embeddedInNavigation(), animated: true)
    }
}
