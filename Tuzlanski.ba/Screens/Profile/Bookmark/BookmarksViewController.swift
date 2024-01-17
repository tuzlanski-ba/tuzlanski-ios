//
//  BookmarksViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 24. 12. 2023..
//

import Foundation
import UIKit

class BookmarksViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .automatic
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.headerTopPadding = 0
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            
            let sectionBackground = NSCollectionLayoutDecorationItem.background(
                elementKind: SectionBackgroundDecorationView.kind)
            section.decorationItems = [sectionBackground]
            
            return section
        }
        
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.kind)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.identifier)
        collectionView.backgroundColor = .screenBackground
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let repository = BookmarkRepository()
    private var bookmarks: [Bookmark] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Spremljene vijesti"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func loadView() {
        view = UIView.screen()
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    // MARK: - Private methods
    
    @objc private func reloadData() {
        bookmarks = repository.bookmarks()
        navigationItem.title = "Sačuvane vijesti \(bookmarks.count > 0 ? "(" + String(bookmarks.count) + ")" : "")"
        collectionView.refreshControl?.endRefreshing()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView delegates

extension BookmarksViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.identifier, for: indexPath) as! ArticleCollectionViewCell
        cell.configure(article: bookmarks[indexPath.row].listArticle)
        cell.isCommentCountVisible = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleViewController = ArticleViewController(listArticle: bookmarks[indexPath.row].listArticle)
        navigationController?.pushViewController(articleViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let unbookmarkAction = UIAction(title: "Ukloni iz spremljenih vijesti", image: UIImage(named: "bookmark")) { [weak self] _ in
                guard let self else { return }
                repository.remove(bookmark: bookmarks[indexPath.row])
                reloadData()
            }
            
            return UIMenu(title: "", children: [unbookmarkAction])
        }
        
        return context
    }
}
