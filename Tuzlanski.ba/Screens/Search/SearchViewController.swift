//
//  SearchViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 12. 2023..
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { [unowned self] index, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.separatorConfiguration.topSeparatorVisibility = .hidden
            configuration.separatorConfiguration.bottomSeparatorVisibility = .automatic
            configuration.separatorConfiguration.bottomSeparatorInsets = .zero
            configuration.headerTopPadding = 0
            
            return .list(using: configuration, layoutEnvironment: environment)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).forAutoLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ArticleCollectionViewCell.self, forCellWithReuseIdentifier: ArticleCollectionViewCell.identifier)

        return collectionView
    }()
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private var articles: [ListArticle] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pretraga"
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pretraži članke"
        searchController.searchBar.setValue("Zatvori", forKey: "cancelButtonText")
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func loadView() {
        view = UIView.screen()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.pin(to: view)
    }
    
    // MARK: - Private methods
}

// MARK: - UICollectionView delegates

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCollectionViewCell.identifier, for: indexPath) as! ArticleCollectionViewCell
        cell.configure(article: articles[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articleViewController = ArticleViewController(listArticle: articles[indexPath.row])
        navigationController?.pushViewController(articleViewController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: Trim text and fire request to server
        // TODO: Add debounce
    }
}
