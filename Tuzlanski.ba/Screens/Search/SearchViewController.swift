//
//  SearchViewController.swift
//  Tuzlanski.ba
//
//  Created by Tarik Dahic on 25. 12. 2023..
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let introductionText = "Za pretragu je potrebno unijeti minimalno 3 slova"
        static let noResultsTest = "Nema rezultata za unešeni pojam"
    }
    
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
    
    private lazy var searchInfoLabel: UILabel = {
        let searchInfoLabel = UILabel().forAutoLayout()
        searchInfoLabel.textAlignment = .center
        searchInfoLabel.numberOfLines = 0
        searchInfoLabel.text = Constants.introductionText
        searchInfoLabel.font = .Montserrat(.semibold, size: 14)
        searchInfoLabel.textColor = .systemGray
        
        return searchInfoLabel
    }()
    
    // MARK: - Properties
    
    private let httpClient = TuzlanskiHttpClient()
    private var articles: [ListArticle] = []
    private var page = 0
    private var isFetching = false
    private var canFetchMore = true
    private var searchQuery: String = "" {
        didSet {
            page = 0
            articles = []
            canFetchMore = true
            isFetching = false
            
            if searchQuery.count > 2 {
                searchInfoLabel.isHidden = true
                loadNextPage()
            } else {
                searchInfoLabel.text = Constants.introductionText
                searchInfoLabel.isHidden = false
                collectionView.reloadData()
            }
        }
    }
    
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
        
        view.addSubview(searchInfoLabel)
        NSLayoutConstraint.activate([
            searchInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            searchInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            searchInfoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Private methods
    
    private func loadNextPage() {
        guard !isFetching && canFetchMore else { return }
        isFetching = true
        Task {
            do {
                page += 1
                let articles = try await httpClient.searchArticles(query: searchQuery, page: page)
                
                if articles.count < TuzlanskiHttpClient.pageLimit {
                    canFetchMore = false
                }
                
                await MainActor.run {
                    self.articles.append(contentsOf: articles)
                    collectionView.reloadData()
                    collectionView.refreshControl?.endRefreshing()
                    isFetching = false
                    
                    if self.articles.isEmpty {
                        searchInfoLabel.text = Constants.noResultsTest
                        searchInfoLabel.isHidden = false
                    } else {
                        searchInfoLabel.isHidden = true
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - UICollectionView delegates

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if articles.count - 5 == indexPath.row {
            loadNextPage()
        }
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
        let text = searchController.searchBar.text?.cleaned() ?? ""
        
        DispatchQueue.main.asyncDeduped(target: self, after: 0.3) {
            self.searchQuery = text
        }
    }
}
