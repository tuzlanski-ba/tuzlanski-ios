//
//  UserCommentsViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 22. 12. 2023..
//

import UIKit

class UserCommentsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.headerTopPadding = 0
            
            return .list(using: configuration, layoutEnvironment: environment)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserCommentCollectionViewCell.self, forCellWithReuseIdentifier: UserCommentCollectionViewCell.identifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private var comments: [UserCommentsResponse.UserComment] = []
    private var categories: [Int64: MenuItemWithParent] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Moji komentari"
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if comments.isEmpty {
            collectionView.refreshControl?.beginRefreshing()
            loadData()
        }
    }
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .primaryBackground
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    // MARK: - Private methods
    
    @objc private func loadData() {
        Task {
            do {
                let rawCategories =  try await httpClient.fetchRawCategories()
                for rawCategory in rawCategories.values {
                    categories[rawCategory.id] = MenuItemWithParent(menuItem: rawCategory)
                    for childRawCategory in rawCategory.childs ?? [] {
                        categories[childRawCategory.id] = MenuItemWithParent(menuItem: childRawCategory, parent: rawCategory)
                    }
                }
                
                let comments = try await httpClient.getUserComments()
                
                await MainActor.run {
                    self.comments = comments
                    collectionView.internal_reload()
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - UICollectionView delegates

extension UserCommentsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCommentCollectionViewCell.identifier, for: indexPath) as! UserCommentCollectionViewCell
        cell.configure(comment: comments[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let comment = comments[indexPath.row]
        guard let category = categories[comment.article.section_id] else { return }
        let section = ListArticleSection(name: category.menuItem.name, path: category.menuItem.name, slug_short: category.menuItem.slug_short, color_hex: category.menuItem.color_hex ?? category.parent?.color_hex ?? "")
        let articleViewController = ArticleViewController(listArticle: comment.article.toListArticle(section: section))
        navigationController?.pushViewController(articleViewController, animated: true)
    }
}
